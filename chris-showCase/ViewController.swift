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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!){
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            if facebookError != nil{
                print("fb login failed. error \(facebookError)")
            } else{
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("successfully logged in with fb \(accessToken)")
            }
        }
    }
    

    
}

