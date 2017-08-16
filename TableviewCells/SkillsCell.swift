//
//  SkillsCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/16/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol SkillsCellDelegate {
    func editSkills()
}

class SkillsCell: UITableViewCell {

    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: SkillsCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editSkills()
    }
    
    func configureCell(individualProfile: IndividualProfile, viewOnly: Bool) {
        
        editButton.isHidden = viewOnly
        
        if let skills = individualProfile.skills {
            if !skills.isEmpty {
                skillsLabel.text = skills
                skillsLabel.textColor = UIColor.black
                skillsLabel.textAlignment = .left
            }
            else {
                skillsLabel.text = "[ Skills ]"
                skillsLabel.textColor = Global.grayColor
                skillsLabel.textAlignment = .center
            }
        }
        else {
            skillsLabel.text = "[ Skills ]"
            skillsLabel.textColor = Global.grayColor
            skillsLabel.textAlignment = .center
        }
    }
}
