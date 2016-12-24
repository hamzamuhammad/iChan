//
//  PostViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/20/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostDelegate {
    
    // basic ref to database
    let ref = FIRDatabase.database().reference()
    
    let imagePicker = UIImagePickerController()
    
    var thread: Thread?
    var chosenImage: UIImage?
    
    var postManager: PostManager?
    
    var threadTableViewController: ThreadTableViewController?
    
    var replyQueue: [String]?

    @IBOutlet var postButton: UIButton!
    @IBOutlet var postText: UITextView!
    @IBOutlet var imageName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        postManager = PostManager()
        postManager!.postDelegate = self
        imagePicker.delegate = self
        imageName.text = ""
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func submitPost(_ sender: Any) {
        postButton.isEnabled = false
        postManager!.createPost(thread: thread!, text: postText.text!, image: chosenImage)
    }
    
    func updateOtherUserReplies(userID: String) {
        // sort pages for given board based off of date
        let query = ref.child("users")
        
        // get all of the posts for the board
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // go through each post
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                // create the user and then modify it
                let user = User(snapshot: rest)
                let createdPosts = user.createdPosts
                
                // could make more efficient by exiting after if is hit
                for reply in self.replyQueue! {
                    for post in createdPosts! {
                        if reply == post {
                            // add our own postID to the user's reply array && update firebase
                            user.repliesToThisUser!.append(userID)
                            let replyUpdate = ["users/\(user.tempID)/repliesToThisUser": user.repliesToThisUser!]
                            self.ref.updateChildValues(replyUpdate)
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            // shouldn't get here
        }
    }
    
    func objectDidPost(userID: String) {
        // update corresponding user values
        updateOtherUserReplies(userID: userID)
        
        // add to our own user data as well
        User.sharedUser.createdPosts!.append(userID)
        let replyUpdate = ["users/\(User.sharedUser.tempID!)/createdPosts": User.sharedUser.createdPosts!]
        ref.updateChildValues(replyUpdate)
        
        // if all goes well, display an alert to user
        let alertController = UIAlertController(title: "Post Successful!", message: "Press OK to dismiss", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true) { () -> () in
            self.postButton.isEnabled = true
        }
    }
    
    func objectFailedPost() {
        // no text entered, so present error
        let alertController = UIAlertController(title: "Post Unsuccessful...", message: "Please enter some text!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true) { () -> () in
            self.postButton.isEnabled = true
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageName.text = pickedImage.description
            chosenImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
