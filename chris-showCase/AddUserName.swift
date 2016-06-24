//
//  AddUserName.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class AddUserName: UIViewController {

    @IBOutlet weak var username: MaterialTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func update(sender: AnyObject){
        if username.text != nil && username.text != ""{
            self.updateUsernameWithFirebase{ () -> () in
                self.performSegueWithIdentifier(SEGUE_USERNAME_TO_FEEDVC, sender: nil)
            }
        }
    }
    
    func updateUsernameWithFirebase(completed: DownloadComplete){
        let userName = DataService.ds.REF_USERS_CURRENT.child("userName")
        userName.setValue(username.text)
        completed()
    }
    
    

}
