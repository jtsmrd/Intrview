//
//  InterviewTemplateDetailsCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/18/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol InterviewTemplateDetailsCellDelegate {
    func editInterviewtemplateDetails(interviewTemplate: InterviewTemplate)
}

class InterviewTemplateDetailsCell: UITableViewCell {

    @IBOutlet weak var interviewTitleLabel: UILabel!
    @IBOutlet weak var interviewDescriptionLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var interviewTemplate: InterviewTemplate!
    var delegate: InterviewTemplateDetailsCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(interviewTemplate: InterviewTemplate, viewOnly: Bool) {
        
        self.interviewTemplate = interviewTemplate
        
        editButton.isHidden = viewOnly
        
        if let jobTitle = interviewTemplate.jobTitle {
            self.interviewTitleLabel.text = jobTitle
        }
        else {
            self.interviewTitleLabel.text = "Interview Title"
        }
        
        if let jobDescription = interviewTemplate.jobDescription {
            self.interviewDescriptionLabel.text = jobDescription
        }
        else {
            self.interviewDescriptionLabel.text = "Interview Description"
        }
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editInterviewtemplateDetails(interviewTemplate: self.interviewTemplate)
    }
}
