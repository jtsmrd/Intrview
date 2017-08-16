//
//  CustomTextField.swift
//  SnapInterview
//
//  Created by JT Smrdel on 2/1/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    var borderColor: UIColor = UIColor.lightText
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
    }
}
