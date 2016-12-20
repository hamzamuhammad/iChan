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
    
    private var _title: String!
    private var _date: Date!
    private var _userID: String!
    private var _text: String!
    var image: UIImage?
    private var _threadID: String!
    private var _threadLen: Int!
    private var _imageName: String!
    var isEmpty: Int!
    
    var title: String {
        return _title
    }
    
    var date: Date {
        return _date
    }
    
    var userID: String {
        return _userID
    }
    
    var text: String {
        return _text
    }
    
    var threadID: String {
        return _threadID
    }
    
    var threadLen: Int {
        return _threadLen
    }
    
    override init() {
        _title = ""
        _date = Date()
        _userID = ""
        _text = ""
        _threadID = ""
        _threadLen = 0
        _imageName = ""
        isEmpty = 1
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        _title = snapshotValue["title"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        _date = dateFormatter.date(from: snapshotValue["date"] as! String)
        
        _userID = snapshotValue["userID"] as! String
        _text = snapshotValue["text"] as! String
        _threadID = snapshotValue["threadID"] as! String
        _threadLen = snapshotValue["threadLen"] as! Int
        isEmpty = snapshotValue["isEmpty"] as! Int
    }
    
    func toAnyObject() -> Any {
        return [
            "title": _title,
            "date": _date,
            "userID": _userID,
            "text": _text,
            "image": _imageName,
            "threadID": _threadID,
            "threadLen": _threadLen,
            "isEmpty": isEmpty
        ]
    }
}
