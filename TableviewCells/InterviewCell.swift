//
//  InterviewCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/27/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class InterviewCell: UITableViewCell {

    @IBOutlet weak var interviewTitleLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(interview: Interview, profileName name: String, isNew: Bool) {
        
        self.interviewTitleLabel.text = interview.interviewTitle
        self.profileNameLabel.text = name
        self.statusLabel.text = interview.interviewStatus
        
        if isNew {
            self.interviewTitleLabel.textColor = UIColor.black
            self.profileNameLabel.textColor = UIColor.black
            self.statusLabel.textColor = UIColor.black
        }
        else {
            self.interviewTitleLabel.textColor = Global.grayColor
            self.profileNameLabel.textColor = Global.grayColor
            self.statusLabel.textColor = Global.grayColor
        }
    }
}
