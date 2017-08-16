//
//  ResumeCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/15/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol ResumeCellDelegate {
    func viewResume()
    func editResume()
}

class ResumeCell: UITableViewCell {
    
    @IBOutlet weak var resumeNameLabel: UILabel!
    @IBOutlet weak var viewResumeButton: CustomButton!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: ResumeCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editResume()
    }
    
    @IBAction func viewResumeButtonAction(_ sender: Any) {
        delegate.viewResume()
    }
    
    func configureCell(individualProfile: IndividualProfile, viewOnly: Bool) {
        
        editButton.isHidden = viewOnly
        
        if let resumeName = individualProfile.resumeName {
            self.resumeNameLabel.text = resumeName
            self.viewResumeButton.setTitle("View Resume", for: .normal)
        }
        else {
            self.resumeNameLabel.text = nil
            self.viewResumeButton.setTitle("No Resume", for: .normal)
        }
    }
}
