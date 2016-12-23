//
//  PostManager.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/22/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol PostDelegate: class {
    func objectDidPost()
    func objectFailedPost()
}

class PostManager: NSObject {
    
    // Basic reference to our database
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    // allows NewThreadViewController (NTVC) to listen to our commands
    weak var postDelegate: PostDelegate?
    
    func createPost(thread: Thread, text: String, image: UIImage?) {
        if text == "" {
            postDelegate!.objectFailedPost()
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        let date = dateFormatter.string(from: Date())
        let userID = NSUUID().uuidString
        
        // have to upload image as well
        if let imageUpload = image {
            // Data in memory
            let data = UIImageJPEGRepresentation(imageUpload, 0.0)!
            
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
                // after this, we're good, so tell user post has been submitted
                
                // here, update the post count for main post
                let threadPost = ["\(thread.ID!)/\(thread.mainPostID!)/threadLen": thread.len + 1]
                self.ref.updateChildValues(threadPost)
                
                // update it for the thread preview as well
                let threadPreview = ["pages/\(EagarPageLoader.getSavedBoard())/\(thread.mainPostID!)/threadLen": thread.len + 1]
                self.ref.updateChildValues(threadPreview)
                
                // 'bump' the corresponding thread
                let bumpUpdate = ["pages/\(EagarPageLoader.getSavedBoard())/\(thread.mainPostID!)/date": date]
                self.ref.updateChildValues(bumpUpdate)
                
                // update the already loaded page with new length
                thread.currentPageView.page!.getPost(index: thread.pagePostIndex).threadLen = thread.currentPageView.page!.getPost(index: thread.pagePostIndex).threadLen + 1
                
                let dict = [
                    "title": "",
                    "date": date,
                    "userID": userID,
                    "text": text,
                    "threadID": thread.ID,
                    "threadLen": thread.len,
                    "isEmpty": 0
                    ] as [String : Any]
                
                // add this to the thread as a post
                self.ref.child(thread.ID).child(userID).setValue(dict)
                // fully loaded, so notify whatever VC called this method
                self.postDelegate!.objectDidPost()
            }
        }
    }
    
    func createThread(title: String, text: String, image: UIImage?) {
        // no image? create an error for the user
        guard image != nil else {
            postDelegate!.objectFailedPost()
            return
        }
        
        // generate values to place into post
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        let date = dateFormatter.string(from: Date())
        let userID = NSUUID().uuidString
        let threadID = NSUUID().uuidString
        
        // make JSON object
        let dict = [
            "title": title,
            "date": date,
            "userID": userID,
            "text": text,
            "threadID": threadID,
            "threadLen": 1,
            "isEmpty": 0
            ] as [String : Any]
        
        // set this as a new 'thread'
        ref.child("pages").child(EagarPageLoader.getSavedBoard()).child(userID).setValue(dict)
        
        // also add this to the actual thread object (as the first post)
        ref.child(threadID).child(userID).setValue(dict)
        
        if let imageUpload = image {
            // Data in memory
            let data = UIImageJPEGRepresentation(imageUpload, 0.0)!
            
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
                
                // let NTVC know that it can post an alert
                self.postDelegate!.objectDidPost()
            }
        }
        else {
            postDelegate!.objectDidPost()
        }
    }
}
