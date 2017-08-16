//
//  SelectInterviewTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol SelectInterviewTVCDelegate {
    func interviewSelected(interviewTemplate: InterviewTemplate)
}

class SelectInterviewTVC: UITableViewController {
    
    var interviewTemplates: [InterviewTemplate] = []
    var delegate: SelectInterviewTVCDelegate!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Interview Types"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interviewTemplates = (profile.businessProfile?.interviewTemplateCollection.interviewTemplates)!
        sortInterviewTemplates()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func backButtonAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    private func sortInterviewTemplates() {
        
        interviewTemplates.sort { (t1, t2) -> Bool in
            t1.displayOrder < t2.displayOrder
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interviewTemplates.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "DefaultCell")
        let item = interviewTemplates[indexPath.row]
        cell.textLabel?.text = item.jobTitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let interviewTemplate = interviewTemplates[indexPath.row]
        delegate.interviewSelected(interviewTemplate: interviewTemplate)
        _ = self.navigationController?.popViewController(animated: true)
    }
}
