//
//  InterviewsTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/24/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import NotificationCenter

class InterviewsTVC: UITableViewController {
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var individualInterviewDetailVC: IndividualInterviewDetailVC!
    var businessInterviewDetailVC: BusinessInterviewDetailVC!
    
    var interviews: [Interview] {
        get {
            switch profile.profileType! {
            case .Business:
                return (profile.businessProfile?.interviewCollection.interviews)!
            case .Individual:
                return (profile.individualProfile?.interviewCollection.interviews)!
            }
        }
        set(interviews) {
            switch profile.profileType! {
            case .Business:
                profile.businessProfile?.interviewCollection.interviews = interviews
            case .Individual:
                profile.individualProfile?.interviewCollection.interviews = interviews
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
        
        tableView.register(UINib(nibName: "InterviewCell", bundle: nil), forCellReuseIdentifier: "InterviewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var newInterviewCount = 0
        
        switch profile.profileType! {
        case .Business:
            
            navigationItem.title = "Active Interviews"
            businessInterviewDetailVC = BusinessInterviewDetailVC(nibName: "BusinessInterviewDetailVC", bundle: nil)
            
            newInterviewCount = interviews.filter({ (interview) -> Bool in
                interview.businessNewFlag == true
            }).count
            
        case .Individual:
            
            navigationItem.title = "Interviews"
            individualInterviewDetailVC = IndividualInterviewDetailVC(nibName: "IndividualInterviewDetailVC", bundle: nil)
            
            newInterviewCount = interviews.filter({ (interview) -> Bool in
                interview.individualNewFlag == true
            }).count
        }
        
        if newInterviewCount > 0 {
            DispatchQueue.main.async {
                self.tabBarItem.badgeValue = "\(newInterviewCount)"
            }
        }
        else {
            DispatchQueue.main.async {
                self.tabBarItem.badgeValue = nil
            }
        }
        
        sortAndRefreshInterviews()
    }
    
    func sortAndRefreshInterviews() {
        
        interviews.sort { (int1, int2) -> Bool in
            int1.createDate! > int2.createDate!
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.interviews.count > 0 {
            return interviews.count
        }
        else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch profile.profileType! {
            
        case .Business:
            
            if !interviews.isEmpty {
                let interviewCell = tableView.dequeueReusableCell(withIdentifier: "InterviewCell", for: indexPath) as! InterviewCell
                interviewCell.configureCell(interview: interviews[indexPath.row], profileName: interviews[indexPath.row].individualName!, isNew: interviews[indexPath.row].businessNewFlag)
                return interviewCell
            }
            else {
                let noDataCell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
                noDataCell.textLabel?.text = "No Active Interviews"
                noDataCell.textLabel?.textColor = Global.grayColor
                noDataCell.textLabel?.textAlignment = .center
                return noDataCell
            }
            
        case .Individual:
            
            if !interviews.isEmpty {
                let interviewCell = tableView.dequeueReusableCell(withIdentifier: "InterviewCell", for: indexPath) as! InterviewCell
                interviewCell.configureCell(interview: interviews[indexPath.row], profileName: interviews[indexPath.row].businessName!, isNew: interviews[indexPath.row].individualNewFlag)
                return interviewCell
            }
            else {
                let noDataCell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
                noDataCell.textLabel?.text = "No Interviews Yet"
                noDataCell.textLabel?.textColor = Global.grayColor
                noDataCell.textLabel?.textAlignment = .center
                return noDataCell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedInterview = interviews[indexPath.row]
        
        switch profile.profileType! {
        case .Business:
            
            businessInterviewDetailVC.interview = selectedInterview
            navigationController?.pushViewController(businessInterviewDetailVC, animated: true)
            
        case .Individual:
            
            individualInterviewDetailVC.interview = selectedInterview
            navigationController?.pushViewController(individualInterviewDetailVC, animated: true)
            
        }
    }    
}
