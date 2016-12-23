//
//  NewThreadViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class NewThreadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    let imagePicker = UIImagePickerController()
    
    var postManager: PostManager?
    
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var textField: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func uploadImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postThread(_ sender: Any) {
        postButton.isEnabled = false
        postManager!.createThread(title: titleField.text!, text: textField.text!, image: imageView.image)
    }
    
    func objectDidPost() {
        // if all goes well, display an alert to user
        let alertController = UIAlertController(title: "Post Successful!", message: "Press OK to dismiss", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true) { () -> () in
            self.postButton.isEnabled = true
        }
    }
    
    func objectFailedPost() {
        // no image, display error
        let alertController = UIAlertController(title: "Failed to Post...", message: "Please upload an image!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true) { () -> () in
            self.postButton.isEnabled = true
        }
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        postManager = PostManager()
        postManager!.postDelegate = self
        imagePicker.delegate = self
        self.title = "New Thread"
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
