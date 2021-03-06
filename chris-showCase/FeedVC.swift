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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()    //we initialize this as empty b/c numberOfRowsInSection will look at this
    
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImg: UIImageView!
    @IBOutlet weak var submitTextBtn: UIButton!
    
    
    var imgPicker: UIImagePickerController!
    
    var currentUsername = String()

    
    static var imageCache = NSCache()  //static means one instance in memory that can be accessed from anywhere
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedRowHeight = 330
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedVC.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        //below is a closure, so it won't be called right away, only when data changes.  Even though this is in viewDidLoad it will be called over and over again.  .Value below gives us whole entire list of posts.  So we need to repopulate entire list when new data comes in
        
        var dictionaryOfUser = Dictionary<String, AnyObject>()
        
        DataService.ds.REF_USERS.observeEventType(.Value, withBlock: { snapshotA in
            if let snapshotter = snapshotA.value as? Dictionary<String, AnyObject>{
                dictionaryOfUser = snapshotter
            }
            self.tableView.reloadData()
        })
        
        
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)        //data that is in the snapshot of our data
            self.posts = [] //we are going to completely clear out posts when we update b/c we need to replace all the data
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        
                        if let id = postDict["userID"] as? String{
                            if let tempDict = dictionaryOfUser[id] as? Dictionary<String, AnyObject>{
                                let post = Post(postKey: key, dictionary: postDict, userInfo: tempDict)     //passing in the userinfo for the user that made that post
                                self.posts.append(post)
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })

        DataService.ds.REF_USERS_CURRENT.child("userName").observeEventType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull{
                print("I'm null")
            } else{
                self.currentUsername = (snapshot.value as? String)!
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.editKey(_:)), name: "editBtnNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.letsSegue(_:)), name: "segueToCommentsNotification", object: nil)
    }
    
    func lookAtSnapshot(completed: DownloadComplete){
        
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
            if let url = post.imageUrl{
                img = FeedVC.imageCache.objectForKey(url) as? UIImage //we are using name FeedVC instead of like self b/c it is publically available and it's static.  Url is our key b/c it is unique.  So the idea is we are going to check the cache to see if we already have the image, and if we don't we'll download it
            }
            
            cell.configureCell(post, img: img)  //if above code doesn't work we will pass in an empty image
            
            return cell
        } else{
            return PostCell()
        }
    }
    
    
    //Don't need this b/c of our commands in viewdidload
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let post = posts[indexPath.row]
//        if post.imageUrl == nil{
//            return UITableViewAutomaticDimension
//        } else{
//            return tableView.estimatedRowHeight
//        }
//    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImg.image = image
    }
    
    @IBAction func selectImg(sender: UITapGestureRecognizer) {
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if inEditMode{
            submitTextBtn.setTitle("POST", forState: .Normal)
        }
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
                    case .Success(let upload, _, _): upload.responseJSON(completionHandler: { response in  //.success and .Failure are part of the multiPartFormData above
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
            "userName": self.currentUsername,
            "userID": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)!,
            "Likes": 0
        ]
        
        if imgURL != nil{
            post["imgURL"] = imgURL
        }
        
        print("is this right? \(submitTextBtn.currentTitle)")
        
        if inEditMode{
            inEditMode = false

            print("i'm edited!")
            DataService.ds.REF_POSTS.child(postKey).child("Description").setValue(postField.text)
            
            if imgURL != nil{
                DataService.ds.REF_POSTS.child(postKey).child("imgURL").setValue(imgURL)
            }
            
        } else{
            print("I'm not edited")
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
            
            //////////////////////////////////////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            let recordPostInUser = DataService.ds.REF_USERS_CURRENT.child("Posts").child(firebasePost.key)
            recordPostInUser.setValue(true)
        }
        textFieldShouldReturn(postField)
        postField.text = ""
        imageSelectorImg.image = UIImage(named: "camera")
        tableView.reloadData()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    
    
    func dismissKeyboard() {
        if inEditMode{
            inEditMode = false
        }
        postField.text = ""
        view.endEditing(true)
    }
    
    func deleteKey(postKeyA: String){
        DataService.ds.REF_POSTS.child(postKeyA).removeValue()
        DataService.ds.REF_USERS_CURRENT.child("Posts").child(postKeyA).removeValue()
    }
    
    var inEditMode: Bool = false
    var postKey: String!
    var postDesc: String!
    
    func editKey(notification: NSNotification){
        
        postDesc = notification.userInfo!["disc"] as? String
        postKey = notification.userInfo!["key"] as? String
        print(notification.userInfo)
        print("ahhh \(postDesc)")
        print("keyyy \(postKey)")
        self.postField.text = postDesc
        self.postField.becomeFirstResponder()
        submitTextBtn.setTitle("EDIT", forState: .Normal)
        inEditMode = true
        // DataService.ds.REF_POSTS.child(postKeyA).setValue()
    }

    func letsSegue(notification: NSNotification){
        print("nice 2")
        var postForSegue = notification.userInfo
        performSegueWithIdentifier("CommentVC", sender: postForSegue)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("3 rhino")
        if segue.identifier == "CommentVC"{
            print("4 rhino")
            if let commentVC = segue.destinationViewController as? CommentVC{
                print("5 rhino")
                print("snake \(sender)")
                if let myPost = sender as? Dictionary<String, Post>{
                    var myPostValue = myPost["love"]
                    print("myHippo \(myPostValue)")
                    commentVC.myPost = myPostValue
                }
            }
        }
    }
    
    @IBAction func settingsPage(sender: AnyObject){
        performSegueWithIdentifier("SettingVC", sender: nil)
    }
    
    
    
    
    
}









