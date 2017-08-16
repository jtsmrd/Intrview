//
//  CustomButton.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/18/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {

    @IBInspectable var buttonColor: UIColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        layer.borderWidth = 1.0
        layer.borderColor = buttonColor.cgColor
        setTitleColor(buttonColor, for: .normal)
        layer.cornerRadius = 5.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}
