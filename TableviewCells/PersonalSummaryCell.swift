//
//  PersonalSummaryCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/15/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol PersonalSummaryCellDelegate {
    func editPersonalSummary()
}

class PersonalSummaryCell: UITableViewCell {

    @IBOutlet weak var personalSummaryLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: PersonalSummaryCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editPersonalSummary()
    }
    
    func configureCell(individualProfile: IndividualProfile, viewOnly: Bool) {
        
        editButton.isHidden = viewOnly
        
        if let personalSummary = individualProfile.personalSummary {
            if !personalSummary.isEmpty {
                personalSummaryLabel.text = personalSummary
                personalSummaryLabel.textColor = UIColor.black
                personalSummaryLabel.textAlignment = .left
            }
            else {
                personalSummaryLabel.text = "[ Personal Summary ]"
                personalSummaryLabel.textColor = Global.grayColor
                personalSummaryLabel.textAlignment = .center
            }
        }
        else {
            personalSummaryLabel.text = "[ Personal Summary ]"
            personalSummaryLabel.textColor = Global.grayColor
            personalSummaryLabel.textAlignment = .center
        }
    }
}
