//
//  ProfileTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/16/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

enum ViewType {
    case Edit
    case ViewOnly
    case SendInterview
    case SendSpotlight
}

class ProfileTVC: UITableViewController, SectionHeaderVCDelegate, IndividualProfileCellDelegate, BusinessProfileCellNewDelegate, SelectInterviewTVCDelegate, ResumeCellDelegate, PersonalSummaryCellDelegate, SkillsCellDelegate, BusinessProfileAboutCellDelegate {
    
    let viewImageVC = UIViewController()
    
    var settingsBarButtonItem: UIBarButtonItem!
    var settingsVC: UIViewController!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var profileType: ProfileType!
    var viewOnly: Bool = false
    var individualProfile: IndividualProfile?
    var businessProfile: BusinessProfile?
    var viewType: ViewType = ViewType.Edit
    var personalSummaryEditVC: PersonalSummaryEditVC!
    
    // IndividualProfile Section Headers
    
    var resumeHeaderVC: SectionHeaderVC!
    var personalSummaryHeaderVC: SectionHeaderVC!
    var skillsHeaderVC: SectionHeaderVC!
    var experienceHeaderVC: SectionHeaderVC!
    var educationHeaderVC: SectionHeaderVC!
    var individualProfileInfoEditVC: IndividualProfileInfoEditVC!
    var resumeEditVC: ResumeEditVC!
    var skillsEditVC: SkillsEditVC!
    
    // BusinessProfile
    
    var aboutEditVC: AboutEditVC!
    var aboutHeaderVC: SectionHeaderVC!
    var businessProfileInfoEditVC: BusinessProfileInfoEditVC!
    
    // Send Interview BarButtonItems
    
    var backBarButtonItem: UIBarButtonItem!
    var confirmBarButtonItem: UIBarButtonItem!
    var interviewTemplate: InterviewTemplate!
    var selectInterviewTemplateButton: UIButton!
    var spotlightVC: SpotlightVC!
    var imageViewZoomVC: ImageViewZoomVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Profile"
        
        configureViewState()
        
        configureView()
        
        if !viewOnly {
            if !profile.exists {
                switch profile.profileType! {
                case .Business:
                    editBusinessProfile()
                case .Individual:
                    editIndividualProfile()
                }
            }
        }
        else {
            if individualProfile != nil {
                self.profileType = ProfileType.Individual
            }
            else if businessProfile != nil {
                self.profileType = ProfileType.Business
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
    }
    
    // MARK: Private Functions
    
    private func configureViewState() {
        
        switch viewType {
            
        case ViewType.Edit:
            
            settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings_icon"), style: .plain, target: self, action: #selector(settingsBarButtonAction))
            settingsBarButtonItem.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = settingsBarButtonItem
            
        case ViewType.ViewOnly:
            
            backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backBarButtonItemAction))
            backBarButtonItem.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = backBarButtonItem
            
        case ViewType.SendInterview:
            
            backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backBarButtonItemAction))
            backBarButtonItem.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = backBarButtonItem
            
            confirmBarButtonItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(confirmInterviewBarButtonItemAction))
            confirmBarButtonItem.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = confirmBarButtonItem
            confirmBarButtonItem.isEnabled = false
            
            selectInterviewTemplateButton = UIButton()
            selectInterviewTemplateButton.layer.borderWidth = 1
            selectInterviewTemplateButton.layer.cornerRadius = 5
            selectInterviewTemplateButton.layer.borderColor = UIColor.white.cgColor
            selectInterviewTemplateButton.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
            selectInterviewTemplateButton.setTitle("Select", for: .normal)
            selectInterviewTemplateButton.addTarget(self, action: #selector(selectInterviewBarButtonItemAction), for: .touchUpInside)
            
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
            view.addSubview(selectInterviewTemplateButton)
            
            navigationItem.titleView = view
            
        case ViewType.SendSpotlight:
            
            backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backBarButtonItemAction))
            backBarButtonItem.tintColor = UIColor.white
            navigationItem.leftBarButtonItem = backBarButtonItem
            
            let spotlightButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showSpotlight))
            spotlightButtonItem.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = spotlightButtonItem
        }
    }
    
    private func saveInterview() {
        
        let interview = Interview()
        interview.businessProfileCKRecordName = self.profile.businessProfile?.cKRecordName
        interview.businessName = self.profile.businessProfile?.name
        interview.individualProfileCKRecordName = self.individualProfile?.cKRecordName
        interview.individualName = self.individualProfile?.name
        interview.createDate = Date()
        interview.interviewStatus = InterviewStatus.Pending.rawValue
        interview.interviewTemplate = self.interviewTemplate
        interview.interviewTemplateCKRecordName = self.interviewTemplate.cKRecordName
        interview.individualNewFlag = true
        interview.interviewTitle = self.interviewTemplate.jobTitle
        interview.interviewDescription = self.interviewTemplate.jobDescription
        
        interview.save {
            self.profile.businessProfile?.subscribeToInterviewRecord(interviewCKRecordName: interview.cKRecordName!, individualName: (self.individualProfile?.name)!)
            self.profile.businessProfile?.interviewCollection.interviews.append(interview)
            
            DispatchQueue.main.async {
                self.alert("Success", message: "Interview request sent!")
            }
        }
    }
    
    private func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func configureView() {
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "BusinessProfileCellNew", bundle: nil), forCellReuseIdentifier: "BusinessProfileCellNew")
        tableView.register(UINib(nibName: "BusinessProfileAboutCell", bundle: nil), forCellReuseIdentifier: "BusinessProfileAboutCell")
        
        tableView.register(UINib(nibName: "WorkExperienceCell", bundle: nil), forCellReuseIdentifier: "WorkExperienceCell")
        tableView.register(UINib(nibName: "IndividualProfileCell", bundle: nil), forCellReuseIdentifier: "IndividualProfileCell")
        tableView.register(UINib(nibName: "EducationCell", bundle: nil), forCellReuseIdentifier: "EducationCell")
        tableView.register(UINib(nibName: "PersonalSummaryCell", bundle: nil), forCellReuseIdentifier: "PersonalSummaryCell")
        tableView.register(UINib(nibName: "ResumeCell", bundle: nil), forCellReuseIdentifier: "ResumeCell")
        tableView.register(UINib(nibName: "SkillsCell", bundle: nil), forCellReuseIdentifier: "SkillsCell")
        
        settingsVC = SettingsVC(nibName: "SettingsVC", bundle: nil)
        imageViewZoomVC = ImageViewZoomVC(nibName: "ImageViewZoomVC", bundle: nil)
        
        individualProfileInfoEditVC = IndividualProfileInfoEditVC(nibName: "IndividualProfileInfoEditVC", bundle: nil)
        businessProfileInfoEditVC = BusinessProfileInfoEditVC(nibName: "BusinessProfileInfoEditVC", bundle: nil)
        personalSummaryEditVC = PersonalSummaryEditVC(nibName: "PersonalSummaryEditVC", bundle: nil)
        resumeEditVC = ResumeEditVC(nibName: "ResumeEditVC", bundle: nil)
        skillsEditVC = SkillsEditVC(nibName: "SkillsEditVC", bundle: nil)
        aboutEditVC = AboutEditVC(nibName: "AboutEditVC", bundle: nil)
        spotlightVC = SpotlightVC(nibName: "SpotlightVC", bundle: nil)
        
        // IndividualProfile Section Headers
        
        resumeHeaderVC = SectionHeaderVC(nibName: "SectionHeaderVC", bundle: nil)
//        resumeHeaderVC.delegate = self
        resumeHeaderVC.sectionType = SectionType.Resume
        resumeHeaderVC.sectionTitle = "Resume"
        resumeHeaderVC.viewOnly = true
        
        personalSummaryHeaderVC = SectionHeaderVC(nibName: "SectionHeaderVC", bundle: nil)
//        personalSummaryHeaderVC.delegate = self
        personalSummaryHeaderVC.sectionType = SectionType.PersonalSummary
        personalSummaryHeaderVC.sectionTitle = "Personal Summary"
        personalSummaryHeaderVC.viewOnly = true
        
        skillsHeaderVC = SectionHeaderVC(nibName: "SectionHeaderVC", bundle: nil)
//        skillsHeaderVC.delegate = self
        skillsHeaderVC.sectionType = SectionType.Skills
        skillsHeaderVC.sectionTitle = "Skills"
        skillsHeaderVC.viewOnly = true
        
        experienceHeaderVC = SectionHeaderVC(nibName: "SectionHeaderVC", bundle: nil)
        experienceHeaderVC.delegate = self
        experienceHeaderVC.sectionType = SectionType.WorkExperience
        experienceHeaderVC.sectionTitle = "Experience"
        experienceHeaderVC.viewOnly = self.viewOnly
        
        educationHeaderVC = SectionHeaderVC(nibName: "SectionHeaderVC", bundle: nil)
        educationHeaderVC.delegate = self
        educationHeaderVC.sectionType = SectionType.Education
        educationHeaderVC.sectionTitle = "Education"
        educationHeaderVC.viewOnly = self.viewOnly
        
        aboutHeaderVC = SectionHeaderVC(nibName: "SectionHeaderVC", bundle: nil)
//        aboutHeaderVC.delegate = self
        aboutHeaderVC.sectionType = SectionType.About
        aboutHeaderVC.sectionTitle = "About"
        aboutHeaderVC.viewOnly = true
    }
    
    // MARK: SkillsCellDelegate Functions
    
    func editSkills() {
        navigationController?.pushViewController(skillsEditVC, animated: true)
    }
    
    // MARK: PersonalSummaryCellDelegate Functions
    
    func editPersonalSummary() {
        navigationController?.pushViewController(personalSummaryEditVC, animated: true)
    }
    
    // MARK: ResumeCellDelegate Functions
    
    func editResume() {
        navigationController?.pushViewController(resumeEditVC, animated: true)
    }
    
    func viewResume() {
        
        if let image = individualProfile?.resumeImage {
            imageViewZoomVC.image = image
            present(imageViewZoomVC, animated: true, completion: nil)
        }
    }
    
    // MARK: BusinessProfileAboutCellDelegate Functions
    
    func editAbout() {
        navigationController?.pushViewController(aboutEditVC, animated: true)
    }
    
    // MARK: SectionHeaderVCDelegate Functions
    
    func editWorkExperience() {
        
        let profileEditTVC = ProfileEditTVC(nibName: "ProfileEditTVC", bundle: nil)
        profileEditTVC.addSectionType = AddSectionType.WorkExperience
        navigationController?.pushViewController(profileEditTVC, animated: true)
    }
    
    func editEducation() {
        
        let profileEditTVC = ProfileEditTVC(nibName: "ProfileEditTVC", bundle: nil)
        profileEditTVC.addSectionType = AddSectionType.Education
        navigationController?.pushViewController(profileEditTVC, animated: true)
    }
    
    // MARK: IndividualProfileCellDelegate Functions
    
    func editIndividualProfile() {
        navigationController?.pushViewController(individualProfileInfoEditVC, animated: true)
    }
    
    func viewProfileImage(image: UIImage) {
        
        let viewImageVC = ViewImageVC()
        viewImageVC.image = image
        present(viewImageVC, animated: true, completion: nil)
    }
    
    func editBusinessProfile() {
        navigationController?.pushViewController(businessProfileInfoEditVC, animated: true)
    }
    
    @objc func showSpotlight() {
        
        spotlightVC.businessProfile = self.businessProfile
        spotlightVC.spotlight = Spotlight()
        navigationController?.pushViewController(spotlightVC, animated: true)
    }
    
    // MARK: Public Functions
    
    // MARK: ViewType.Edit BarButtonItem Functions
    
    @objc func settingsBarButtonAction() {
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: ViewType.SendInterview BarButtonItem Functions
    
    @objc func backBarButtonItemAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func selectInterviewBarButtonItemAction() {
        
        let selectInterviewTVC = SelectInterviewTVC(nibName: "SelectInterviewTVC", bundle: nil)
        selectInterviewTVC.delegate = self
        navigationController?.pushViewController(selectInterviewTVC, animated: true)
    }
    
    func interviewSelected(interviewTemplate: InterviewTemplate) {
        
        self.interviewTemplate = interviewTemplate
        self.selectInterviewTemplateButton.setTitle(self.interviewTemplate.jobTitle, for: .normal)
        self.confirmBarButtonItem.isEnabled = true
    }
    
    @objc func confirmInterviewBarButtonItemAction() {
        
        if (profile.businessProfile?.interviewCollection.identicalPendingInterviewExists(individualProfileCKRecordName: (self.individualProfile?.cKRecordName)!, interviewTemplateCKRecordName: self.interviewTemplate.cKRecordName!))! {
            alert("Existing Interview Pending", message: "There's an existing Active Interview pending for this user.")
        }
        else {
            saveInterview()
            self.confirmBarButtonItem.isEnabled = false
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        switch profileType! {
            
        case ProfileType.Individual:
            return 6
            
        case ProfileType.Business:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch profileType! {
            
        case ProfileType.Individual:
            
            if section == 4 {
                if individualProfile != nil {
                    return (individualProfile?.workExperienceCollection.count)!
                }
                else {
                    return 0
                }
            }
            else if section == 5 {
                if individualProfile != nil {
                    return (individualProfile?.educationCollection.count)!
                }
                else {
                    return 0
                }
            }
            else {
                if individualProfile != nil {
                    return 1
                }
                else {
                    return 0
                }
            }
            
        case ProfileType.Business:
            
            if businessProfile != nil {
                return 1
            }
            else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch profileType! {
            
        case ProfileType.Individual:
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "IndividualProfileCell", for: indexPath) as! IndividualProfileCell
                cell.delegate = self
                cell.configureCell(individualProfile: individualProfile!, viewOnly: self.viewOnly)
                return cell
            }
            else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResumeCell", for: indexPath) as! ResumeCell
                cell.delegate = self
                cell.configureCell(individualProfile: individualProfile!, viewOnly: self.viewOnly)
                return cell
            }
            else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalSummaryCell", for: indexPath) as! PersonalSummaryCell
                cell.delegate = self
                cell.configureCell(individualProfile: individualProfile!, viewOnly: self.viewOnly)
                return cell
            }
            else if indexPath.section == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SkillsCell", for: indexPath) as! SkillsCell
                cell.delegate = self
                cell.configureCell(individualProfile: individualProfile!, viewOnly: self.viewOnly)
                return cell
            }
            else if indexPath.section == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WorkExperienceCell", for: indexPath) as! WorkExperienceCell
                cell.configureCell(workExperience: (individualProfile?.workExperienceCollection[indexPath.row])!, viewOnly: true)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as! EducationCell
                cell.configureCell(education: (individualProfile?.educationCollection[indexPath.row])!, viewOnly: true)
                return cell
            }
            
        case ProfileType.Business:
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessProfileCellNew", for: indexPath) as! BusinessProfileCellNew
                cell.delegate = self
                cell.configureCell(businessProfile: businessProfile!, viewOnly: self.viewOnly)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessProfileAboutCell", for: indexPath) as! BusinessProfileAboutCell
                cell.delegate = self
                cell.configureCell(businessProfile: businessProfile!, viewOnly: self.viewOnly)
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch profileType! {
            
        case ProfileType.Individual:
            
            if indexPath.section == 0 {
                return 600
            }
            else {
                return 116
            }
            
        case ProfileType.Business:
            
            if indexPath.section == 0 {
                return 412
            }
            else {
                return 116
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch profileType! {
            
        case ProfileType.Individual:
            
            if section == 1 {
                return resumeHeaderVC.view
            }
            else if section == 2 {
                return personalSummaryHeaderVC.view
            }
            else if section == 3 {
                return skillsHeaderVC.view
            }
            else if section == 4 {
                return experienceHeaderVC.view
            }
            else if section == 5 {
                return educationHeaderVC.view
            }
            else {
                return nil
            }
            
        case ProfileType.Business:
            
            if section == 1 {
                return aboutHeaderVC.view
            }
            else {
                return nil
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch profileType! {
            
        case ProfileType.Individual:
            
            switch section {
                
            case 1, 2, 3, 4, 5:
                return 34
                
            default:
                return 8
            }
            
        case ProfileType.Business:
            
            if section == 1 {
                return 34
            }
            else {
                return 8
            }
        }
    }    
}
