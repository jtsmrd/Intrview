//
//  ProfileImageView.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/13/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

@IBDesignable class ProfileImageView: UIImageView {
    
    @IBInspectable var borderColor: UIColor = UIColor.green
    
    override func layoutSubviews() {
        layer.cornerRadius = 40
        layer.masksToBounds = true
        layer.borderWidth = 5.0
        layer.borderColor = borderColor.cgColor
    }
}
