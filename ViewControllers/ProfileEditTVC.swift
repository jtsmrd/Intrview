//
//  ProfileEditTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class ProfileEditTVC: UITableViewController, WorkExperienceCellDelegate, AddEntrySectionHeaderVCDelegate, EducationCellDelegate, InterviewTemplateDetailsCellDelegate, InterviewQuestionCellDelegate {
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var addSectionType: AddSectionType!
    var educationCollection = [Education]()
    var workExperienceCollection = [WorkExperience]()
    var interviewTemplate: InterviewTemplate!
    var interviewQuestions = [InterviewQuestion]()
    var workExperienceHeaderVC: AddEntrySectionHeaderVC!
    var addEditWorkExperienceVC: AddEditWorkExperienceVC!
    var educationHeaderVC: AddEntrySectionHeaderVC!
    var addEditEducationVC: AddEditEducationVC!
    var interviewQuestionsHeaderVC: AddEntrySectionHeaderVC!
    var interviewTemplateDetailsEditVC: InterviewTemplateDetailsEditVC!
    var addEditInterviewQuestionVC: AddEditInterviewQuestionVC!
    var saveBarButtonItem: UIBarButtonItem!
    var backBarButtonItem: UIBarButtonItem!
    var viewOnly: Bool = false
    var interviewTemplateVCDelegate: InterviewTemplateVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 128
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            workExperienceCollection = (profile.individualProfile?.workExperienceCollection)!
            tableView.register(UINib(nibName: "WorkExperienceCell", bundle: nil), forCellReuseIdentifier: "WorkExperienceCell")
            
            workExperienceHeaderVC = AddEntrySectionHeaderVC(nibName: "AddEntrySectionHeaderVC", bundle: nil)
            workExperienceHeaderVC.delegate = self
            workExperienceHeaderVC.addSectionType = AddSectionType.WorkExperience
            workExperienceHeaderVC.addSectionTitle = "Edit Experience"
            
            addEditWorkExperienceVC = AddEditWorkExperienceVC(nibName: "AddEditWorkExperienceVC", bundle: nil)
            
        case AddSectionType.Education:
            educationCollection = (profile.individualProfile?.educationCollection)!
            tableView.register(UINib(nibName: "EducationCell", bundle: nil), forCellReuseIdentifier: "EducationCell")
            
            educationHeaderVC = AddEntrySectionHeaderVC(nibName: "AddEntrySectionHeaderVC", bundle: nil)
            educationHeaderVC.delegate = self
            educationHeaderVC.addSectionType = AddSectionType.Education
            educationHeaderVC.addSectionTitle = "Edit Education"
            
            addEditEducationVC = AddEditEducationVC(nibName: "AddEditEducationVC", bundle: nil)
            
        case AddSectionType.InterviewQuestion:
            
            if !viewOnly {
                
                saveBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveInterviewTemplate))
                saveBarButtonItem.tintColor = UIColor.white
                navigationItem.rightBarButtonItem = saveBarButtonItem
                
                interviewTemplateDetailsEditVC = InterviewTemplateDetailsEditVC(nibName: "InterviewTemplateDetailsEditVC", bundle: nil)
                addEditInterviewQuestionVC = AddEditInterviewQuestionVC(nibName: "AddEditInterviewQuestionVC", bundle: nil)
                
                interviewQuestionsHeaderVC = AddEntrySectionHeaderVC(nibName: "AddEntrySectionHeaderVC", bundle: nil)
                interviewQuestionsHeaderVC.delegate = self
                interviewQuestionsHeaderVC.addSectionType = AddSectionType.InterviewQuestion
                interviewQuestionsHeaderVC.addSectionTitle = "Add Interview Question"
            }
            
            interviewQuestions = interviewTemplate.interviewQuestions
            
            tableView.register(UINib(nibName: "InterviewTemplateDetailsCell", bundle: nil), forCellReuseIdentifier: "InterviewTemplateDetailsCell")
            tableView.register(UINib(nibName: "InterviewQuestionCell", bundle: nil), forCellReuseIdentifier: "InterviewQuestionCell")
        }
        
        backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backBarButtonItemAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        tableView.reloadData()
    }

    func editWorkExperience(workExperience: WorkExperience) {
        
        addEditWorkExperienceVC.workExperience = workExperience
        navigationController?.pushViewController(addEditWorkExperienceVC, animated: true)
    }
    
    func editEducation(education: Education) {
        
        addEditEducationVC.education = education
        navigationController?.pushViewController(addEditEducationVC, animated: true)
    }
    
    func addWorkExperience() {
        navigationController?.pushViewController(addEditWorkExperienceVC, animated: true)
    }
    
    func addEducation() {
        navigationController?.pushViewController(addEditEducationVC, animated: true)
    }
    
    func addInterviewQuestion() {
        
        addEditInterviewQuestionVC.interviewTemplate = self.interviewTemplate
        navigationController?.pushViewController(addEditInterviewQuestionVC, animated: true)
    }
    
    func editInterviewtemplateDetails(interviewTemplate: InterviewTemplate) {
        
        interviewTemplateDetailsEditVC.interviewTemplate = interviewTemplate
        navigationController?.pushViewController(interviewTemplateDetailsEditVC, animated: true)
    }
    
    private func saveInterviewQuestionsDisplayOrder() {
        
        for i in 0..<interviewTemplate.interviewQuestions.count {
            interviewTemplate.interviewQuestions[i].displayOrder = i as Int?
        }
    }
    
    @objc func saveInterviewTemplate() {
        
        saveInterviewQuestionsDisplayOrder()
        
        if interviewTemplate.cKRecordName == nil {
            
            // Add new templates to the end of the list by default
            let maxInterviewTemplateOrder = self.profile.businessProfile?.interviewTemplateCollection.interviewTemplates.max { i1, i2 in i1.displayOrder < i2.displayOrder }?.displayOrder
            
            if var templateOrderNumber = maxInterviewTemplateOrder {
                templateOrderNumber += 1
                interviewTemplate.displayOrder = templateOrderNumber
            }
            
            self.interviewTemplateVCDelegate.addInterviewTemplate(interviewTemplate: self.interviewTemplate)
        }
        else {
            interviewTemplate.save(with: (self.profile.businessProfile?.cKRecordName)!) {

            }
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func editInterviewQuestion(interviewQuestion: InterviewQuestion) {
        
        addEditInterviewQuestionVC.interviewTemplate = self.interviewTemplate
        addEditInterviewQuestionVC.interviewQuestion = interviewQuestion
        navigationController?.pushViewController(addEditInterviewQuestionVC, animated: true)
    }
    
    @objc func backBarButtonItemAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            return 1
            
        case AddSectionType.Education:
            return 1
            
        case AddSectionType.InterviewQuestion:
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            return workExperienceCollection.count
            
        case AddSectionType.Education:
            return educationCollection.count
            
        case AddSectionType.InterviewQuestion:
            
            if section == 0 {
                return 1
            }
            else {
                return interviewQuestions.count
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkExperienceCell", for: indexPath) as! WorkExperienceCell
            cell.delegate = self
            cell.configureCell(workExperience: workExperienceCollection[indexPath.row], viewOnly: false)
            return cell
            
        case AddSectionType.Education:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as! EducationCell
            cell.delegate = self
            cell.configureCell(education: educationCollection[indexPath.row], viewOnly: false)
            return cell
            
        case AddSectionType.InterviewQuestion:
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterviewTemplateDetailsCell", for: indexPath) as! InterviewTemplateDetailsCell
                cell.delegate = self
                cell.configureCell(interviewTemplate: interviewTemplate, viewOnly: self.viewOnly)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterviewQuestionCell", for: indexPath) as! InterviewQuestionCell
                cell.delegate = self
                cell.configureCell(interviewQuestion: interviewQuestions[indexPath.row], viewOnly: self.viewOnly)
                return cell
            }
        }
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            return workExperienceHeaderVC.view
            
        case AddSectionType.Education:
            return educationHeaderVC.view
            
        case AddSectionType.InterviewQuestion:
            
            if section == 1 && !viewOnly {
                return interviewQuestionsHeaderVC.view
            }
            else {
                return nil
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch addSectionType! {
            
        case AddSectionType.WorkExperience:
            return 34
            
        case AddSectionType.Education:
            return 34
            
        case AddSectionType.InterviewQuestion:
            
            if section == 1 {
                return 34
            }
            else {
                return 1
            }
        }
    }    
}
