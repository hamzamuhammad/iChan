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

class NewThreadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var textField: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func uploadImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
   
    @IBAction func postThread(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        let date = dateFormatter.string(from: Date())
        let userID = NSUUID().uuidString
        let threadID = NSUUID().uuidString
        let dict = [
            "title": titleField.text!,
            "date": date,
            "userID": userID,
            "text": textField.text!,
            "image": userID,
            "threadID": threadID
        ]
        
        // get the currently saved board
        let defaults = UserDefaults.standard
        
        // we do this whenever the board button is pressed
        // defaults.set("theGreatestName", forKey: "username")
        var board: String = ""
        
        // grab the user's key
        if let userBoard = defaults.string(forKey: "board") {
            board = userBoard
        }
        
        // set this as a new 'thread'
        self.ref.child("pages").child(board).child(userID).setValue(dict)
        
        // have to upload image as well
        
        // Data in memory
        let data = UIImageJPEGRepresentation(imageView.image!, 0.0)!
        
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
