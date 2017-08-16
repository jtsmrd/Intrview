//
//  SpotlightCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/31/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class SpotlightCell: UITableViewCell {

    @IBOutlet weak var spotlightTitleLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(spotlight: Spotlight, profileName name: String, isNew: Bool) {
        
        self.spotlightTitleLabel.text = spotlight.jobTitle
        self.profileNameLabel.text = name
        
        if isNew {
            self.spotlightTitleLabel.textColor = UIColor.black
            self.profileNameLabel.textColor = UIColor.black
        }
        else {
            self.spotlightTitleLabel.textColor = Global.grayColor
            self.profileNameLabel.textColor = Global.grayColor
        }
    }
}
