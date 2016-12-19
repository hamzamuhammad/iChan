//
//  LaunchViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

protocol LoadDelegate {
    func didFetchPosts()
    func didFetchImage(index: Int)
}

class LaunchViewController: UIViewController, LoadDelegate {

    @IBOutlet weak var animationContainer: UIView!
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    private var page: Page = Page()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let view = AnimatedEqualizerView(containerView: animationContainer)
        self.animationContainer.backgroundColor = UIColor.clear
        self.animationContainer.addSubview(view)
        view.animate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // get the currently saved board
        let defaults = UserDefaults.standard

        // we do this whenever the board button is pressed
        // defaults.set("theGreatestName", forKey: "username")
        var board: String = ""
        
        // grab the user's key
        if let userBoard = defaults.string(forKey: "board") {
            board = userBoard
        }
        
        // sort based off of date
        let query = ref.child("pages").child(board).queryOrdered(byChild: "date")
        
        // get the newest 5 posts for a certain board
        query.queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // go through each post
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                
                // create the post and add to the page
                let post = Post(snapshot: rest)
                self.page.addPost(originalPost: post)
            }
            
            // after everything is fully loaded, notify delegate
            self.didFetchPosts()
            //self.performSegue(withIdentifier: "LaunchSegue", sender: self)
        }) { (error) in
            print(error.localizedDescription)
            // after everything is fully loaded, call the segue
            //self.performSegue(withIdentifier: "LaunchSegue", sender: self)
        }
    }
    
    func didFetchPosts() {
        // loop through each post
        downloadImage(index: 0)
    }
    
    func didFetchImage(index: Int) {
        if index + 1 < page.threadPreviews.count {
            downloadImage(index: index + 1)
        }
        else if index + 1 == page.threadPreviews.count {
            self.performSegue(withIdentifier: "LaunchSegue", sender: self)
            print("GOT HERE TWICE")
        }
    }
    
    func downloadImage(index: Int) {
        let post = page.threadPreviews[index]
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(post.userID).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 4 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                post.image = UIImage(data: data!)!
            }
            self.didFetchImage(index: index)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LaunchSegue" {
            // send our page object to the main page view
            let navigationViewController = segue.destination as! UINavigationController
            let pageViewController = navigationViewController.topViewController as! PageViewController
            pageViewController.currentPage = page
        }
    }
}
