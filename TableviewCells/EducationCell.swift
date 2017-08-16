//
//  EducationCellNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/14/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol EducationCellDelegate {
    func editEducation(education: Education)
}

class EducationCell: UITableViewCell {

    @IBOutlet weak var degreeEarnedLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: EducationCellDelegate!
    var education: Education!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(education: Education, viewOnly: Bool) {
        
        self.editButton.isHidden = viewOnly
        
        self.education = education
        self.degreeEarnedLabel.text = education.degreeEarned
        self.schoolNameLabel.text = education.schoolName
        self.schoolLocationLabel.text = education.schoolLocation
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editEducation(education: education)
    }
}
