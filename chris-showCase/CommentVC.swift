//
//  CommentVC.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/27/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Firebase

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentTableView: UITableView!
    var aComment: Dictionary<String, Dictionary<String, String>>!
    var comments = [Comment]()
    
    var myPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        DataService.ds.REF_POSTS.child(myPost.postKey).child("Comments").observeEventType(.Value, withBlock: { snapshot in
            if let snapShots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapShots{
                    if let tempDict = snap.value as? Dictionary<String, String>{
                        print("tiger \(tempDict)")
                        let tempComment = Comment(commentDict: tempDict)
                        self.comments.append(tempComment)
                    }
                }
            }
            
            
            for comment in self.comments{
                DataService.ds.REF_USERS.child(comment.userId).observeEventType(.Value, withBlock: { snapshot in
//                    print("value \(snapshot.value)")
//                    print("key \(snapshot.key)")
//                    print("children \(snapshot.children)")
//                    print("children.objects \(snapshot.children.allObjects)")
//                    print("snapshot \(snapshot)")

                    if let snapShots = snapshot.value{
                        if let snapshot = snapShots as? Dictionary<String, AnyObject>{
                            for comment in self.comments{
                                comment.addUserInfo(snapshot)
                            }
                        }
                    }
                    self.commentTableView.reloadData()
                })
            }
            self.commentTableView.reloadData()
        })
        

        
        
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
        commentTableView.estimatedRowHeight = 200
        commentTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    @IBAction func commentsBtn(sender: AnyObject){
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = commentTableView.dequeueReusableCellWithIdentifier("CommentsCell") as? CommentsCell{
            print("I'm in here")
            cell.configureCell(comments[indexPath.row])
            return cell
        } else{
            return CommentsCell()
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("comments Count \(comments.count)")

        return comments.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func exitTapped(sender: AnyObject!){
        print("tapped")
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
