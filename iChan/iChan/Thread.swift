//
//  Thread.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol PostLoadDelegate: class {
    func didLoadPost(index: Int)
    func didLoadImage(index: Int)
    func reloadTable()
}

class Thread: NSObject {
    
    // make a reference to our database
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")

    var pagePostIndex: Int!
    var ID: String!
    var len: Int!
    var mainPostID: String!
    
    var posts: [Post]?

    var currentPageView: PageTableViewController!
    
    weak var postLoadDelegate: PostLoadDelegate?
        
    init(pagePostIndex: Int, threadID: String, threadLen: Int, mainPostID: String, currentPageView: PageTableViewController) {
        self.pagePostIndex = pagePostIndex
        self.ID = threadID
        self.len = threadLen
        self.mainPostID = mainPostID
        self.currentPageView = currentPageView
        
        posts = []
    }
    
    func loadPostInfo() {
        // get info for our temp user obj
        let query = ref.child("users").child(User.sharedUser.tempID!)
        
        // get all of the posts for the board
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            
            for post in self.posts! {
                for userPost in user.createdPosts! {
                    if post.userID == userPost {
                        post.visibility = "self"
                    }
                }
                
                for replyPost in user.repliesToThisUser! {
                    if post.userID == replyPost {
                        post.visibility = "other"
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            // shouldn't get here
        }
    }
    
    func updateThread() {
        let postRef = FIRDatabase.database().reference().child(ID).queryOrdered(byChild: "date")
        
        _ = postRef.observe(FIRDataEventType.value, with: { (snapshot) in
        
            var tempThread: [Post] = []
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let post = Post(snapshot: rest)
                tempThread.append(post)
            }
            
            tempThread.reverse()
            let start = 0
            let end = tempThread.count - self.posts!.count
            if end > start {
                for i in start..<end {
                    self.posts!.append(tempThread[i])
                    self.len = self.len + 1
                    self.updateDownloadImage(index: self.posts!.count - 1)
                }
            }
        })
    }
    
    func updateDownloadImage(index: Int) {
        let post = posts![index]
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(post.userID!).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("error: \(error.debugDescription)")
            } else {
                post.image = UIImage(data: data!)!
            }
            
            // this is fully loaded, so we can return an image
            self.posts![index].isEmpty = 0
            // notify tableview that this image has been downloaded
            if let delegate = self.postLoadDelegate {
                delegate.reloadTable()
            }
            return
        }
    }
    
    func lazyLoad() {
        
        // sort based off of date
        let query = ref.child(ID).queryOrdered(byChild: "date")
        
        // get all posts
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // go through each post
            var index: Int = 0
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                
                // create the post and add to thread; inform tableview to reload text
                let post = Post(snapshot: rest)
                self.posts![index] = post
                self.postLoadDelegate!.didLoadPost(index: index)

                // since we cant get the image yet, we have to download it!
                self.downloadImage(index: index)
                
                index = index + 1
            }
            // should call update method after this
        }) { (error) in
            print(error.localizedDescription)
            // shouldn't get here
        }
    }
    
    // MARK: - Singular image download function
    
    func downloadImage(index: Int) {
        let post = posts![index]
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(post.userID!).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("error: \(error.debugDescription)")
            } else {
                post.image = UIImage(data: data!)!
            }
            
            // this is fully loaded, so we can return an image
            self.posts![index].isEmpty = 0
            // notify tableview that this image has been downloaded
            self.postLoadDelegate!.didLoadImage(index: index)
        }
    }
}
