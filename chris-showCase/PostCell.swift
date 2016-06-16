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
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post! //we need to store post
    var request: Request?   //reason we need to store Alamo fire request is b/c we need to cancel it, normally don't need to store request
    var likeRef: FIRDatabaseReference!
    
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
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
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
}









