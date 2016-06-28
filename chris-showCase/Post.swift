//
//  Post.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/13/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation
import Firebase

class Post{
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _profileImageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _userID: String!
    private var _comment: Dictionary<String, Dictionary<String, String>>!
    
    var postDescription: String{
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var profileImageUrl: String?{
        return _profileImageUrl
    }
    
    var likes: Int{
        return _likes
    }
    
    var userName: String{
        if _username == nil{
            _username = ""
        }
        return _username
    }
    
    var postKey: String{
        return _postKey
    }
    
    var userID: String{
        return _userID
    }
    
    var comment: Dictionary<String, Dictionary<String, String>>!{
        if _comment == nil{
            _comment = Dictionary()
        }
        return _comment
    }
    
    init(description: String, imgUrl: String?, username: String){
        self._postDescription = description
        self._imageUrl = imgUrl
        self._username = username
    }
    
    //we want to convert data from firebase into a dictionary,  when we grab data from firebase we will pass in dictionary,parse data out so we can use it
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>, userInfo: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        if let likes = dictionary["Likes"] as? Int{
            self._likes = likes
        }
        
        if let imgURL = dictionary["imgURL"] as? String{
            self._imageUrl = imgURL
        }
        
        if let profileImgURL = userInfo["imageURL"] as? String{
            self._profileImageUrl = profileImgURL
        }
        
        if let comment = dictionary["Comments"] as? Dictionary<String, Dictionary<String, String>>{
            self._comment = comment
            print("eagle \(self._comment)")
        }
        
        if let description = dictionary["Description"] as? String{
            self._postDescription = description
        }
        
        if let username = userInfo["userName"] as? String{
            self._username = username
        }
        
        if let userid = dictionary["userID"] as? String{
            self._userID = userid
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    func adjustLikes(addLike: Bool){
        if addLike{
            _likes = _likes + 1
        } else{
            _likes = _likes - 1
        }
        
        _postRef.child("Likes").setValue(_likes)
    }
    
    
}