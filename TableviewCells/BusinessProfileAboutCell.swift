//
//  BusinessProfileAboutCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/16/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol BusinessProfileAboutCellDelegate {
    func editAbout()
}

class BusinessProfileAboutCell: UITableViewCell {

    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: BusinessProfileAboutCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editAbout()
    }    
    
    func configureCell(businessProfile: BusinessProfile, viewOnly: Bool) {
        
        editButton.isHidden = viewOnly
        
        if let about = businessProfile.about {
            aboutLabel.text = about
            aboutLabel.textColor = UIColor.black
            aboutLabel.textAlignment = .left
        }
        else {
            aboutLabel.text = "[ About ]"
            aboutLabel.textColor = Global.grayColor
            aboutLabel.textAlignment = .center
        }
    }
}
