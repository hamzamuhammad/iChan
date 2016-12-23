//
//  PostViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/20/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    let imagePicker = UIImagePickerController()
    
    var thread: Thread?
    var chosenImage: UIImage?
    
    var postManager: PostManager?
    
    var threadTableViewController: ThreadTableViewController?

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
    
    func objectDidPost() {
        // allow table refreshment
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
