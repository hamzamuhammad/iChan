//
//  Page.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/22/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol PreviewLoadDelegate {
    func didLoadPreviews(posts: [String])
}

class Page: NSObject {
    
    private var threadPreviews: [Post] = []
    
    var previewLoadDelegate: PreviewLoadDelegate?
    
    func getPost(index: Int) -> Post {
        return threadPreviews[index]
    }
    
    func addPost(post: Post) {
        threadPreviews.append(post)
    }
    
    func numPreviewThreads() -> Int {
        return threadPreviews.count
    }
    
    func getPreviewPosts(index: Int) {
        // make a reference to our database
        let ref = FIRDatabase.database().reference()
        
        // get 5 latest posts, sort based off of date
        let query = ref.child(threadPreviews[index].threadID).queryOrdered(byChild: "date").queryLimited(toLast: 5)
        
        // get all posts
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            var stringPosts: [String] = []
            
            // go through each post
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                
                // create the post and add to thread
                let post = Post(snapshot: rest)
                stringPosts.append(post.text)
            }
            // notify popover to display w/ just text strings
            self.previewLoadDelegate?.didLoadPreviews(posts: stringPosts)
        }) { (error) in
            print(error.localizedDescription)
            // shouldn't get here
        }
    }
}
