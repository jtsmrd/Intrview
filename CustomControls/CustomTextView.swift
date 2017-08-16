//
//  CustomTextView.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/22/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

@IBDesignable class CustomTextView: UITextView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.groupTableViewBackground.cgColor
        layer.cornerRadius = 5
    }
}
