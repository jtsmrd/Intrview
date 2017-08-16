//
//  CustomLabel.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/23/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

@IBDesignable class CustomLabel: UILabel {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        layer.cornerRadius = 5
    }
}
