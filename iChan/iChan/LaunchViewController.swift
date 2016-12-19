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

class LaunchViewController: UIViewController {

    @IBOutlet weak var animationContainer: UIView!
    
    let ref = FIRDatabase.database().reference()
    
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
        
        board = "tv"
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
            print("get here")
            // after everything is fully loaded, call the segue
            self.performSegue(withIdentifier: "LaunchSegue", sender: self)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // after everything is fully loaded, call the segue
        performSegue(withIdentifier: "LaunchSegue", sender: self)
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
