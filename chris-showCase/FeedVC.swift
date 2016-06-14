//
//  FeedVC.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/10/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
   // var imagePicker: UIImagePickerController!
    var posts = [Post]()    //we initialize this as empty b/c numberOfRowsInSection will look at this
    static var imageCache = NSCache()  //static means one instance in memory that can be accessed from anywhere
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 344
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
}









