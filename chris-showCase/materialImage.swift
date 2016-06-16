//
//  materialImage.swift
//  chris-showCase
//
//  Created by Chris Hovey on 6/15/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class materialImage: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = 2
        clipsToBounds = true
    }

}
