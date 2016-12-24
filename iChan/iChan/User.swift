//
//  User.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/23/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import FirebaseDatabase

class User: NSObject {
    // singleton
    static let sharedUser: User = {
        let instance = User()
        
        // setup code
        
        return instance
    }()
    
    // Basic reference to our database
    let ref = FIRDatabase.database().reference()
    
    var tempID: String?
    var threadID: String?
    
    var createdPosts: [String]?
    var repliesToThisUser: [String]?
    
    override init() {
        let tempID = NSUUID().uuidString
        self.tempID = tempID
        threadID = ""
        
        createdPosts = ["a"]
        repliesToThisUser = ["b"]
        
        // add to local storage
        // get the currently saved board
        let defaults = UserDefaults.standard
        
        // we do this whenever the board button is pressed
        defaults.set(tempID, forKey: "ID")
        
        // add to firebase
        let dict = [
            "createdPosts": createdPosts! as NSArray,
            "repliesToThisUser": repliesToThisUser! as NSArray
        ] as [String : Any]
        ref.child("users").child(tempID).setValue(dict)
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        createdPosts = snapshotValue["createdPosts"] as? [String]
        repliesToThisUser = snapshotValue["repliesToThisUser"] as? [String]
    }
    
    func toAnyObject() -> Any {
        return [
            "createdPosts": createdPosts,
            "repliesToThisUser": repliesToThisUser
        ]
    }
}
