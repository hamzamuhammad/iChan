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

class Post: NSObject {
    
    var title: String!
    var date: Date!
    var userID: String!
    var text: String!
    var image: UIImage?
    var threadID: String!
    var threadLen: Int!
    var isEmpty: Int!
    var visibility: String!
    
    override init() {
        title = ""
        date = Date()
        userID = ""
        text = ""
        threadID = ""
        threadLen = 0
        isEmpty = 1
        visibility = "default"
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        title = snapshotValue["title"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        date = dateFormatter.date(from: snapshotValue["date"] as! String)
        
        userID = snapshotValue["userID"] as! String
        text = snapshotValue["text"] as! String
        threadID = snapshotValue["threadID"] as! String
        threadLen = snapshotValue["threadLen"] as! Int
        isEmpty = snapshotValue["isEmpty"] as! Int
        visibility = snapshotValue["visibility"] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            "title": title,
            "date": date,
            "userID": userID,
            "text": text,
            "threadID": threadID,
            "threadLen": threadLen,
            "isEmpty": isEmpty,
            "visibility": visibility
        ]
    }
}
