//
//  EagarPageLoader.swift
// -> pull and return initial thread previews (pages) from database for a given board
//
//  iChan
//
//  Created by Hamza Muhammad on 12/22/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

// let LaunchViewController (LVC) when to exit loading screen and segue to main app
protocol LaunchAppDelegate: class {
    func didFinishLoading()
}

class EagarPageLoader: NSObject {
    
    // Basic reference to our database
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    var posts: [Post]?
    
    // allows LVC to listen to our commands
    weak var launchAppDelegate: LaunchAppDelegate?
    
    override init() {
        posts = []
    }
    
    class func getSavedBoard() -> String {
        // get the currently saved board
        let defaults = UserDefaults.standard
        
        // grab the user's key
        if let userBoard = defaults.string(forKey: "board") {
            return userBoard
        }
        
        return ""
    }
    
    func mainFetchLoop() {
        // sort pages for given board based off of date
        let query = ref.child("pages").child(EagarPageLoader.getSavedBoard()).queryOrdered(byChild: "date")
        
        // get all of the posts for the board
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // go through each post
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                // create the post and add to our posts
                let post = Post(snapshot: rest)
                self.posts!.append(post)
            }
            
            // go ahead and start fetching the images for each post
            if self.posts!.count > 0 {
                self.downloadImages(index: 0)
            }
            else {
                // no pages for this board, so let LVC know to load anyways
                self.launchAppDelegate?.didFinishLoading()
            }
        }) { (error) in
            print(error.localizedDescription)
            // shouldn't get here
        }
    }
    
    // MARK: - Recursive image download function
    
    func downloadImages(index: Int) {
        if index < posts!.count {
            let post = posts![index]
            
            // Create a reference to the file you want to download
            let imageRef = storageRef.child("images/\(post.userID).jpg")
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    // Uh-oh, an error occurred!
                } else {
                    post.image = UIImage(data: data!)!
                }
                self.downloadImages(index: index + 1)
            }
        }
        else {
            self.launchAppDelegate?.didFinishLoading()
        }
    }
    
    func generatePages() -> [Page] {
        var numPages: Int = 0
        
        if posts!.count % 5 == 0 {
            numPages = posts!.count / 5
        }
        else {
            numPages = posts!.count / 5 + 1
        }
        
        var pages: [Page] = []
        
        var index: Int = posts!.count - 1
        for i in 0..<numPages {
            pages.append(Page())
            
            // add to a page (where the max # posts for the page is 5
            var lim: Int = 5
            while index >= 0 && lim > 0 {
                pages[i].addPost(post: posts![index])
                index = index - 1
                lim = lim - 1
            }
        }
        return pages
    }
}
