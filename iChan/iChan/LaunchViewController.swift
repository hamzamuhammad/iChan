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
        
        // pull data for the first page
        ref.child("\(board)_0").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get full page and set up objects
            let value = snapshot.value as? NSDictionary
            
            let username = value?["username"] as? String ?? ""
            let user = User.init(username: username)
            
            // ...
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
            // prepare the main app for this
            print("get here")
            
        }
    }

}
