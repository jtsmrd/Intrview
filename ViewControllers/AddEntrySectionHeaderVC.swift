//
//  AddEntrySectionHeaderVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol AddEntrySectionHeaderVCDelegate {
    
    func addWorkExperience()
    func addEducation()
    func addInterviewQuestion()
}

enum AddSectionType {
    
    case WorkExperience
    case Education
    case InterviewQuestion
}

class AddEntrySectionHeaderVC: UIViewController {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    var addSectionType: AddSectionType!
    var delegate: AddEntrySectionHeaderVCDelegate!
    var addSectionTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sectionTitleLabel.text = addSectionTitle
        view.backgroundColor = UIColor.clear
    }

    @IBAction func addButtonAction(_ sender: Any) {
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            delegate.addWorkExperience()
            
        case AddSectionType.Education:
            delegate.addEducation()
            
        case AddSectionType.InterviewQuestion:
            delegate.addInterviewQuestion()
        }
    }
}
