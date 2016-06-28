//
//  PostCell.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/10/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Alamofire
import Firebase


class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descTextLbl: UILabel!
    
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var bottomSpace: UIView!
    
    
    
    var post: Post! //we need to store post
    var request: Request?   //reason we need to store Alamo fire request is b/c we need to cancel it, normally don't need to store request
    var likeRef: FIRDatabaseReference!
    var usersPostRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        //can't include below in awake from Nib b/c the frame and size have not yet been set
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true

    }

    func configureCell(post: Post, img: UIImage?){      //passing in an image if it exists
        self.post = post
        self.likeRef = DataService.ds.REF_USERS_CURRENT.child("likes").child(post.postKey)
        self.usersPostRef = DataService.ds.REF_USERS_CURRENT.child("Posts").child(post.postKey)
        
        
        self.descTextLbl.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.username.text = post.userName
        
        if post.imageUrl != nil{
            self.showcaseImg.hidden = false
            if img != nil{      //here we are checking if there was an image passed in from the cache
                self.showcaseImg.image = img
            } else{
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in  //the image/* just means that we are optimizing for images
                    if err == nil{      //in completionHandler, if error is not nil then grab it
                        if let img = UIImage(data: data!){
                            self.showcaseImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        }
                    }
                })
            }
        } else {
            self.showcaseImg.hidden = true
        }
        print("my prof image \(post.profileImageUrl)")
        if post.profileImageUrl != nil{
            self.profileImg.hidden = false
            if let img = FeedVC.imageCache.objectForKey(post.profileImageUrl!) as? UIImage{
                self.profileImg.image = img
            } else{
                request = Alamofire.request(.GET, post.profileImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: {request, response, data, err in
                    if err == nil{
                        if let img1 = UIImage(data: data!){
                            self.profileImg.image = img1
                            FeedVC.imageCache.setObject(img1, forKey: self.post.profileImageUrl!)
                        }
                    }
                })
            }
        } else{
            self.profileImg.hidden = true
        }
        
        usersPostRef.observeEventType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull{
                self.deleteBtn.hidden = true
                self.editBtn.hidden = true
//                self.bottomSpace.hidden = true
            } else{
                self.deleteBtn.hidden = false
                self.editBtn.hidden = false
//                self.bottomSpace.hidden = false
            }
        })
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull{    //in firebase, data that doesn't exist is an NSNull
                //This means we have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty")
            } else{
                self.likeImg.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull{    //in firebase, data that doesn't exist is an NSNull
                //This means we have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else{
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    
    @IBAction func commentsBtn(sender: AnyObject){
        print("nice")
//        print("1 I'm called now rhino\(post.comment)")
//        var dictionary = post.comment
        let myPost = post
//        NSNotificationCenter.defaultCenter().postNotificationName("segueToCommentsNotification", object: nil, userInfo: dictionary)
        NSNotificationCenter.defaultCenter().postNotificationName("segueToCommentsNotification", object: nil, userInfo: ["love": myPost])
    }

    
    
    @IBAction func deleteCell(sender: UIButton){
        FeedVC().deleteKey(post.postKey)
    }
    
    @IBAction func editBtnPress(sender: UIButton){
        var dictionary = ["disc": post.postDescription, "key": post.postKey]

        NSNotificationCenter.defaultCenter().postNotificationName("editBtnNotification", object: nil, userInfo: dictionary)
        //FeedVC().editKey(post.postDescription, postKeyA: post.postKey)
    }
    
}





