//
//  WorkExperienceCellNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/14/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol WorkExperienceCellDelegate {
    func editWorkExperience(workExperience: WorkExperience)
}

class WorkExperienceCell: UITableViewCell {

    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: WorkExperienceCellDelegate!
    var workExperience: WorkExperience!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(workExperience: WorkExperience, viewOnly: Bool) {
        
        self.editButton.isHidden = viewOnly
        
        self.workExperience = workExperience
        self.jobTitleLabel.text = workExperience.jobTitle
        self.companyLabel.text = workExperience.employerName
        self.dateRangeLabel.text = Global.dateFormatter.string(from: workExperience.startDate!)
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editWorkExperience(workExperience: workExperience)
    }
}
