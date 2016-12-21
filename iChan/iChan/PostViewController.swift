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

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    let imagePicker = UIImagePickerController()
    
    var threadLen: Int!
    var threadID: String!
    var mainPostID: String!
    var chosenImage: UIImage!
    
    var currentPageView: PageTableViewController!
    var postIndex: Int!

    @IBOutlet var postText: UITextView!
    @IBOutlet var imageName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imageName.text = ""
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func submitPost(_ sender: Any) {
        let title = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        let date = dateFormatter.string(from: Date())
        let userID = NSUUID().uuidString
        let threadID = self.threadID
        
        // here, update the post count for main post
        let threadPost = ["\(threadID!)/\(mainPostID!)/threadLen": threadLen + 1]
        ref.updateChildValues(threadPost)
        
        let defaults = UserDefaults.standard

        var board: String = ""
        // grab the user's key
        if let userBoard = defaults.string(forKey: "board") {
            board = userBoard
        }
        
        let threadPreview = ["pages/\(board)/\(mainPostID!)/threadLen": threadLen + 1]
        ref.updateChildValues(threadPreview)
        
        
        currentPageView!.page.threadPreviews[postIndex!].threadLen = currentPageView!.page.threadPreviews[postIndex!].threadLen + 1
        
        let isEmpty = 0
        let dict = [
            "title": title,
            "date": date,
            "userID": userID,
            "text": postText.text!,
            "image": userID,
            "threadID": threadID!,
            "threadLen": threadLen,
            "isEmpty": isEmpty
            ] as [String : Any]
        
        // add this to the thread as a post
        self.ref.child(threadID!).child(userID).setValue(dict)

        // have to upload image as well
        
        // Data in memory
        let data = UIImageJPEGRepresentation(chosenImage!, 0.0)!
        
        // Create a reference to the file you want to upload
        let imgRef = storageRef.child("images/\(userID).jpg")
        
        // Upload the file to the path "images/userID.jpg"
        _ = imgRef.put(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            _ = metadata.downloadURL
        }
        
        // if all goes well, display an alert to user
        let alertController = UIAlertController(title: "Post Successful!", message: "Press OK to dismiss", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
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
