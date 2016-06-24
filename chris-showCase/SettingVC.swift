//
//  SettingVC.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import Alamofire

class SettingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var profilePic: materialImage!
    @IBOutlet weak var userName: MaterialTextField!
    var tapRec: UITapGestureRecognizer!
    
    var imgPicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        tapRec = UITapGestureRecognizer()
        
        tapRec.addTarget(self, action: #selector(SettingVC.presentImgVC))
        tapRec.delegate = self
        profilePic.userInteractionEnabled = true
        profilePic.addGestureRecognizer(tapRec)
    }
    
    @IBAction func update(sender: AnyObject){
        if let img = profilePic.image where profilePic.image != UIImage(named: "User-100"){
            let urlString = "https://post.imageshack.us/upload_api.php"
            let url = NSURL(string: urlString)!
            let imgData = UIImageJPEGRepresentation(img, 0.2)!
            let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            
            Alamofire.upload(.POST, url, multipartFormData: { (MultipartFormData) in
                MultipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                MultipartFormData.appendBodyPart(data: keyData, name: "key")
                MultipartFormData.appendBodyPart(data: keyJSON, name: "format")
            }) { encodingResult in
                switch encodingResult{
                case .Success(let upload, _, _): upload.responseJSON(completionHandler: {response in
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
        }
    }
    
    func postToFirebase(imgLink: String?){
        let imagePost = DataService.ds.REF_USERS_CURRENT.child("imageURL")
        imagePost.setValue(imgLink)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        profilePic.image = image
        makeProfilePicRound()
    }
    
    func presentImgVC (){
        print("i'm called")
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    func makeProfilePicRound(){
        if profilePic.image != UIImage(named: "User-100"){
            profilePic.contentMode = UIViewContentMode.ScaleAspectFill
            profilePic.layer.cornerRadius = profilePic.frame.height / 2
            profilePic.clipsToBounds = true
        }
    }


}
