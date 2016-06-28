//
//  CommentsCell.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/27/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        
        
    }
    
    override func drawRect(rect: CGRect) {
        profilePic.layer.cornerRadius = profilePic.frame.width / 2
        profilePic.clipsToBounds = true
    }

    func configureCell(comment: Comment){
        lbl.text = comment.text
//        name.text = comment.userName
    }
}
