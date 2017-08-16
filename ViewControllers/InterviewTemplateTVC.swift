//
//  InterviewTemplateTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/25/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol InterviewTemplateVCDelegate {
    func addInterviewTemplate(interviewTemplate: InterviewTemplate)
}

class InterviewTemplateTVC: UITableViewController, InterviewTemplateVCDelegate {
    
    // MARK: Variables
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    
    var interviewTemplates: [InterviewTemplate] {
        get {
            return (profile.businessProfile?.interviewTemplateCollection.interviewTemplates)!
        }
        set(interviewTemplates) {
            profile.businessProfile?.interviewTemplateCollection.interviewTemplates = interviewTemplates
        }
    }
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationItem.rightBarButtonItem?.isEnabled = Global.iCloudContainerIsAvailable()
        
        if interviewTemplates.count == 0 {
            self.profile.businessProfile?.interviewTemplateCollection.insertDefaultTemplate()
        }
        
        sortInterviewTemplates()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Interview Types"
        navigationItem.rightBarButtonItem = editButtonItem
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
        
        editButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: UIControlState())
    }
    
    private func sortInterviewTemplates() {
        
        if interviewTemplates.count > 1 {
            interviewTemplates.sort { (t1, t2) -> Bool in
                t1.displayOrder < t2.displayOrder
            }
        }
    }
    
    private func saveInterviewTemplatesDisplayOrder() {
        
        for i in 0..<interviewTemplates.count {
            interviewTemplates[i].displayOrder = i
        }
    }
    
    private func save() {
        
        saveInterviewTemplatesDisplayOrder()
        for template in interviewTemplates {
            template.save(with: profile.cKRecordName!, completion: {
                
            })
        }
    }
    
    // MARK: - InterviewTemplateVCDelegate
    
    func addInterviewTemplate(interviewTemplate: InterviewTemplate) {
        
        interviewTemplates.append(interviewTemplate)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        interviewTemplate.save(with: profile.cKRecordName!) {
            
        }
    }
    
    // MARK: - Table View Data Source Methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            tabBarController?.tabBar.isHidden = true
        }
        else {
            tabBarController?.tabBar.isHidden = false
            save()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        return interviewTemplates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TemplateCell")
        if indexPath.section == 0 {
            cell.textLabel?.text = "Create New"
            cell.textLabel?.textColor = Global.greenColor
            cell.textLabel?.textAlignment = .center
        }
        else {
            let item = interviewTemplates[indexPath.row]
            cell.textLabel?.text = item.jobTitle
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.textAlignment = .left
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let profileEditTVC = ProfileEditTVC(nibName: "ProfileEditTVC", bundle: nil)
        profileEditTVC.addSectionType = AddSectionType.InterviewQuestion
        profileEditTVC.interviewTemplateVCDelegate = self
        
        if interviewTemplates.count > 0 && indexPath.section == 1 {
            profileEditTVC.interviewTemplate = interviewTemplates[indexPath.row]
        }
        else {
            profileEditTVC.interviewTemplate = InterviewTemplate()
        }
        
        navigationController?.pushViewController(profileEditTVC, animated: true)
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        
        if fromIndexPath == toIndexPath {
            return
        }
        
        let movedItem = interviewTemplates[fromIndexPath.row]
        interviewTemplates.remove(at: fromIndexPath.row)
        interviewTemplates.insert(movedItem, at: toIndexPath.row)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let templateToDelete = interviewTemplates.remove(at: indexPath.row)
            
            templateToDelete.delete()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 1 {
            return true
        }
        return false
    }    
}
