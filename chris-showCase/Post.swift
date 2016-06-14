//
//  Post.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/13/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation

class Post{
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    
    var postDescription: String{
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int{
        return _likes
    }
    
    var userName: String{
        return _username
    }
    
    init(description: String, imgUrl: String?, username: String){
        self._postDescription = description
        self._imageUrl = imgUrl
        self._username = username
    }
    
    //we want to convert data from firebase into a dictionary,  when we grab data from firebase we will pass in dictionary,parse data out so we can use it
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        if let likes = dictionary["Likes"] as? Int{
            self._likes = likes
        }
        
        if let imgURL = dictionary["imgURL"] as? String{
            self._imageUrl = imgURL
        }
        
        if let description = dictionary["Description"] as? String{
            self._postDescription = description
        }
    }
    
    
    
    
}