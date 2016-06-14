//
//  DataService2.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/9/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()       //this gets the DATABASE_URL from the GoogleServices-Info.plist


//thi is a place where we can store references to firebase
//singleton - single instance of an object or class that we have access to
class DataService{
    
    //in our Data service we want to implement some things that can interact with firebase
    static let ds = DataService()   //static property means there is only one instance in memory

    private var _REF_BASE = URL_BASE    // a reference to my specific firebase account, so info can save in the database
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    
    var REF_Base: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference{
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference{
        return _REF_USERS
    }
    
    var REF_USERS_CURRENT: FIRDatabaseReference{
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
        REF_USERS.child(uid).setValue(user)     //set value might supposed to be "child" again
    }
    
    
}