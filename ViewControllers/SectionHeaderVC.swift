//
//  WorkExperienceHeaderVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/14/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol SectionHeaderVCDelegate {
    
    func editWorkExperience()
    func editEducation()
    func editPersonalSummary()
    func editResume()
    func editSkills()
    func editAbout()
}

enum SectionType {
    
    case WorkExperience
    case Education
    case PersonalSummary
    case Resume
    case Skills
    case About
}

class SectionHeaderVC: UIViewController {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var sectionType: SectionType!
    var delegate: SectionHeaderVCDelegate!
    var sectionTitle: String!
    var viewOnly: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sectionTitleLabel.text = sectionTitle
        editButton.isHidden = viewOnly
        
        view.backgroundColor = UIColor.clear
    }

    @IBAction func editButtonAction(_ sender: Any) {
        
        switch sectionType! {
            
        case SectionType.WorkExperience:
            delegate.editWorkExperience()
            
        case SectionType.Education:
            delegate.editEducation()
            
        case SectionType.PersonalSummary:
            delegate.editPersonalSummary()
            
        case SectionType.Resume:
            delegate.editResume()
            
        case SectionType.Skills:
            delegate.editSkills()
            
        case SectionType.About:
            delegate.editAbout()
        }
    }
}
