//
//  Comment.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/28/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import Firebase

class Comment{
    private var _text: String!
    private var _userId: String!
    private var _userName: String?
    private var _imageURL: String?
    
    
    var text: String{
        return _text
    }
    
    var userId: String{
        return _userId
    }
    
    var userName: String?{
        if _userName == nil{
            _userName = ""
        }
        return _userName
    }
    
    var imageURL: String?{
        if _imageURL == nil{
            _imageURL = ""
        }
        return _imageURL
    }
    
    
    init(commentDict: Dictionary<String, String>){
        
        
        if let textA = commentDict["commentText"]{
            self._text = textA
        }
        
        if let userIdA = commentDict["userID"]{
            self._userId = userIdA
        }
        
        //DataService.ds.REF_USERS.child(self._userId)
    }
    
    func addUserInfo(dict: Dictionary<String, AnyObject>){
        self._userName = dict["userName"] as? String
        self._imageURL = dict["imageURL"] as? String
    }
    
    
}