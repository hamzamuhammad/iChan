//
//  LaunchViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LaunchViewController: UIViewController, LaunchAppDelegate {

    @IBOutlet weak var animationContainer: UIView!
    
    var eagarPageLoader: EagarPageLoader?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _ = User.sharedUser
        
        let view = AnimatedEqualizerView(containerView: animationContainer)
        self.animationContainer.backgroundColor = UIColor.clear
        self.animationContainer.addSubview(view)
        view.animate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // fully load the users chosen board before the app launches
        eagarPageLoader = EagarPageLoader()
        eagarPageLoader!.launchAppDelegate = self
        eagarPageLoader!.mainFetchLoop()
    }
    
    func didFinishLoading() {
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
            pageViewController.pages = eagarPageLoader!.generatePages()
        }
    }
}
