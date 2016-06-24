//
//  MaterialView.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/8/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    override func awakeFromNib() {  //called when user interface is loaded from the storyboard
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)//the shadow on the left and right will be 0 and it will go down 2px.  However since we have a shadow radius of 5 then it will extend on the left and right sides.
    }
}