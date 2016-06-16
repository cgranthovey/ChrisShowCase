//
//  FeedVC.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/10/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
   // var imagePicker: UIImagePickerController!
    var posts = [Post]()    //we initialize this as empty b/c numberOfRowsInSection will look at this
    
    
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImg: UIImageView!
    
    
    
    var imgPicker: UIImagePickerController!
    
    static var imageCache = NSCache()  //static means one instance in memory that can be accessed from anywhere
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 377
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
   //     imagePicker = UIImagePickerController()
 //       imagePicker.delegate = self
        
        //below is a closure, so it won't be called right away, only when data changes.  Even though this is in viewDidLoad it will be called over and over again.  .Value below gives us whole entire list of posts.  So we need to repopulate entire list when new data comes in
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            print("first")
            print(snapshot.value)        //data that is in the snapshot of our data
            print("second")
            self.posts = [] //we are going to completely clear out posts when we update b/c we need to replace all the data
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    print ("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            cell.request?.cancel()      //if we are scrolling through and reusing a cell that has appeared before which is still making a request, we want to cancel that request b/c it is not good for the image we want
            var img: UIImage?
            print(img)
            if let url = post.imageUrl{
                img = FeedVC.imageCache.objectForKey(url) as? UIImage //we are using name FeedVC instead of like self b/c it is publically available and it's static.  Url is our key b/c it is unique.  So the ideea is we are going to check the cache to see if we already have the image, and if we don't we'll download it
            }
            
            cell.configureCell(post, img: img)  //if above code doesn't work we will pass in an empty image
            
            return cell
        } else{
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageUrl == nil{
            return 150
        } else{
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImg.image = image
    }
    
    @IBAction func selectImg(sender: UITapGestureRecognizer) {
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != ""{
            if let img = imageSelectorImg.image where imageSelectorImg.image != UIImage(named: "camera"){       //verifying here that we have an imag and that img is not default cam img
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!    //we need to tell their server that we are posting up JSON
                
                Alamofire.upload(.POST, url, multipartFormData: { (multipartFormData) in
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")    //fileupload is name of imageshack api tells us to include with the imgData.  fileName is just a default name of the image that image Shack will rename later
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                }) { encodingResult in      //performed when upload is done.  It will pass back an error or success value
                    switch encodingResult{
                    case .Success(let upload, _, _): upload.responseJSON(completionHandler: { response in  //.success and .Failure are part ofthe multiPartFormData above
                        if let info = response.result.value as? Dictionary<String, AnyObject>{
                            if let links = info["links"] as? Dictionary<String, AnyObject>{
                                if let imageLink = links["image_link"] as? String{
                                    print("LINK: \(imageLink)")
                                    self.postToFirebase(imageLink)
                                }
                            }
                        }
                    })
                    
                    case .Failure(let err): print(err)
                    }
                }
            } else{
                self.postToFirebase(nil)        //if we did not add an image then we will only post a description, so make imgURL nil, there has to be text in the text field b/c we checked for it above
            }
        }
    }
    
    func postToFirebase(imgURL: String?){
        
        //create format of data we want
        var post: Dictionary<String, AnyObject> = [
            "Description": postField.text!,
            "Likes": 0
        ]
        
        if imgURL != nil{
            post["imgURL"] = imgURL
        }
        
        //call reference to POSTS url, add a child onto it by calling function childByAutoId(), then we set value of post
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImg.image = UIImage(named: "camera")
        tableView.reloadData()
    }
    
    
}









