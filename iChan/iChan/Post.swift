//
//  Post.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class Post: NSObject {
    
    private var _title: String!
    private var _date: Date!
    private var _userID: Int!
    private var _text: String!
    private var _image: UIImage?
    private var _threadID: Int!
    
    private var _imageName: String!
    
    var title: String {
        return _title
    }
    
    var date: Date {
        return _date
    }
    
    var userID: Int {
        return _userID
    }
    
    var text: String {
        return _text
    }
    
    var image: UIImage {
        return _image!
    }
    
    var threadID: Int {
        return _threadID
    }
    
    init(title: String, date: Date, userID: Int, text: String, image: UIImage, threadID: Int) {
        _title = title
        _date = date
        _userID = userID
        _text = text
        _image = image
        _threadID = threadID
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        _title = snapshotValue["title"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        _date = dateFormatter.date(from: snapshotValue["date"] as! String)
        
        _userID = snapshotValue["userID"] as! Int
        _text = snapshotValue["text"] as! String
        
        // Get a reference to the storage service using the default Firebase App
        let storage = FIRStorage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference(forURL: "your_firebase_storage_bucket")
        
        _imageName = snapshotValue["image"] as! String
        // Create a reference to the file you want to download
        let imageRef = storageRef.child(_imageName)
        
        var tempImage: UIImage!
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                tempImage = UIImage(data: data!)!
            }
        }
        _image = tempImage
        
        _threadID = snapshotValue["threadID"] as! Int
    }
    
    func toAnyObject() -> Any {
        return [
            "title": _title,
            "date": _date,
            "userID": _userID,
            "text": _text,
            "image": _imageName,
            "threadID": _threadID
        ]
    }
}
