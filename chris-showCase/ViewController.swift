//
//  ViewController.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/8/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FBSDKCoreKit   //in marks video but not in doucmation
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //if user already has logged in before and has a firebase auth key we'll bypass the homescreen
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{  //if key exists then move on
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!){
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            if facebookError != nil{
                print("fb login failed. error \(facebookError)")
            } else{
                //if we successfully get to this point, fb will give us an access token.  we want to be able to talk to Firebase to save a user id which can be associated with facebook
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("successfully logged in with fb \(accessToken)")
                
                
                // if user logs in w/ facebook or email we still need to give them a firebase id.  we want to store on our device the token of the firebase user so next time they log in they won't have to type in a password
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                //we now have the credential, now need to authenticate with firebase using that credential
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error != nil{
                        print("loggin failed \(error)")
                    } else{
                        print("logged in. \(user)")
                        
                        let userData = ["provider": credential.provider]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                        
                        //we are saving to device
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        
                        //if it works we will be taken to next VC after token is saved to device
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
            })
        }
    }
}

    @IBAction func attemptLogin(sender: UIButton!){
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != ""{
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
                if error != nil{
                    print(error)    //possible errors - account doesn't exist, incorrect password, not connected to internet
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST{  //we are checking if the code number is the one for an account not existing.  If it doesn't exist we want to create a user.
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                            
                            if error != nil{    //if we receive an error
                                self.showErrorAlerts("Could not create account", msg: "Problem creating account.  Try something else")
                            } else{     //if we don't receive an error then we can log the user in
                                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)  //saving the user ID
                                let userData = ["provider": "email", "blah": "email test"]
                                DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                    })
                    } else{
                        self.showErrorAlerts("Could Not Log In", msg: "Please check your username and password")
                    }
                } else{
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        } else {
            showErrorAlerts("Email and Password Required", msg: "You must enter an email and password")
        }
    }
    
    
    //
    func showErrorAlerts(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}









