//
//  LoginViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/23/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBAction func facebookLogin(_ sender: Any) {
        // reference to our database
        
        let facebookLogin = FBSDKLoginManager()
        print("Logging in...")
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil { print("Facebook login failed. Error \(facebookError)")
            } else if (facebookResult?.isCancelled)! { print("Facebook login was cancelled.")
            } else {
                print("User logged in.")
                
                let accessToken = FBSDKAccessToken.current().tokenString
                
                FIRAuth.auth()?.signIn(withCustomToken: accessToken ?? "") { (user, error) in
                    // ...
                    if error != nil {
                        print("Login failed. \(error)")
                    }
                    else {
                        print("Logged in! \(user)")
                        
                        var providerID: String?
                        var uid: String?
                        var name: String?
                        var email: String?
                        
                        for profile in user!.providerData {
                            providerID = profile.providerID
                            uid = profile.uid;  // Provider-specific UID
                            name = profile.displayName
                            email = profile.email
                        }
                        
                        let newUser = [
                            "providerID": providerID!,
                            "displayName": name!,
                            "email": email!
                        ]
                        
                        // make a reference to our database
                        let ref = FIRDatabase.database().reference()
                        
                        ref.child("users").child(uid!).setValue(newUser)
                        
                        // segue to loading screen
                        self.performSegue(withIdentifier: "LoginSegue", sender: self)
                    }
                }
                
            }
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
