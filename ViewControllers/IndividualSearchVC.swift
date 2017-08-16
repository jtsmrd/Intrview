//
//  IndividualSearchVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/25/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit
import MessageUI

class IndividualSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMailComposeViewControllerDelegate {

    // MARK: - Variables, Outlets, and Constants
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let profileTVC = ProfileTVC(nibName: "ProfileTVC", bundle: nil)
    
    var searchEmail: String!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var searchResults = [IndividualProfile]()
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Search"
        
        navigationController?.navigationBar.barTintColor = Global.greenColor
        searchBar.tintColor = Global.greenColor
        
//        navigationItem.rightBarButtonItem = editButtonItem
//        editButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: UIControlState())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem?.isEnabled = Global.iCloudContainerIsAvailable()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func fetchIndividualProfile(_ searchEmail: String) {
        
        searchResults.removeAll()
        
        var query: CKQuery!
        
        if searchEmail.contains("@") {
            query = CKQuery(recordType: "IndividualProfile", predicate: NSPredicate(format: "contactEmail = %@", searchEmail))
        }
        else {
            query = CKQuery(recordType: "IndividualProfile", predicate: NSPredicate(format: "searchName BEGINSWITH %@", searchEmail))
        }
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) -> Void in
            
            if let error = error {
                
                if error._code == 1 {
                    self.alert("iCloud Drive Required", message: "You must enable Intrview in iCloud Drive to edit, save, and search.\nSettings-> iCloud-> iCloud Drive-> Toggle Intrview ON")
                }
                else {
                    Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
                }
            }
            else if let records = records {
                
                if !records.isEmpty {
                    
                    for record in records {
                        self.searchResults.append(IndividualProfile(with: record))
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
//                        self.removeInvitationSubscription(searchEmail)
                    }
                }
                else {
                    
                    let alertController = UIAlertController(title: "No users found matching that email.", message: "Send an email invite?\n\nWe'll let you know when they sign up.", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    let inviteAction = UIAlertAction(title: "Invite", style: .default) { (action) in
                        
                        let mailComposeViewController = self.configuredMailComposeViewController()
                        
                        if MFMailComposeViewController.canSendMail() {
                            self.present(mailComposeViewController, animated: false, completion: nil)
                        } else {
                            self.alert("Could not send email invitation.", message: "Your device could not send the invitation")
                        }
                    }
                    
                    alertController.addAction(inviteAction)
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    fileprivate func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([searchEmail])
        mailComposerVC.setSubject("Interview request from \(profile.businessProfile?.name! ?? "[Company]")")
        mailComposerVC.setMessageBody("\(profile.businessProfile?.name! ?? "[Company]") wants to interview you with Intrview. Download it from the iOS App Store.", isHTML: false)
        return mailComposerVC
    }
    
    fileprivate func saveInvitationSubscription() {
        
        let predicate = NSPredicate(format: "contactEmail = %@", searchEmail)
        let subscription = CKQuerySubscription(recordType: "IndividualProfile", predicate: predicate, options: .firesOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "You can now send \(searchEmail!) an Interview."
        notificationInfo.shouldBadge = true
        notificationInfo.category = "IndividualProfileRegisteredNotification"
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription, completionHandler: { (subscription, error) -> Void in
            if let error = error {
                Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
            else if let subscription = subscription {
                print("Successful: \(subscription)")
                
                var interviewSubscriptions = UserDefaults.standard.dictionary(forKey: "InterviewSubscriptions")
                interviewSubscriptions!["\(self.searchEmail)"] = subscription.subscriptionID
                UserDefaults.standard.set(interviewSubscriptions, forKey: "InterviewSubscriptions")
                UserDefaults.standard.synchronize()
            }
        })
    }
    
    fileprivate func removeInvitationSubscription(_ email: String) {
        
        var interviewSubscriptions = UserDefaults.standard.dictionary(forKey: "InterviewSubscriptions")
        let subscriptionID = interviewSubscriptions!["\(email)"] as? String
        
        if subscriptionID != nil {
            CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: subscriptionID!) { (str, error) in
                if let error = error {
                    Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
                }
                else if let str = str {
                    print(str)
                }
            }
        }
    }
    
    fileprivate func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        
        if let searchText = searchBar.text {
            
            searchEmail = searchText.lowercased().replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            fetchIndividualProfile(searchEmail)
        }
        
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    // MARK: - Table View Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchResults.count > 0 {
            if !profile.previousSearchCollection.previousSearches.isEmpty {
                return 2
            }
            else {
                return 1
            }
        }
        else if !profile.previousSearchCollection.previousSearches.isEmpty {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchResults.count > 0 && section == 0 {
            return searchResults.count
        }
        return profile.previousSearchCollection.previousSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SearchResultCell")
        
        if searchResults.count > 0 && indexPath.section == 0 {
            cell.textLabel?.text = searchResults[indexPath.row].name
            cell.detailTextLabel?.text = searchResults[indexPath.row].profession
            return cell
        }
        else {
            cell.textLabel?.text = profile.previousSearchCollection.previousSearches[indexPath.row].name
            cell.detailTextLabel?.text = profile.previousSearchCollection.previousSearches[indexPath.row].profession
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchResults.count > 0 {
            if section == 1 {
                return "Search History"
            }
            else {
                return "Search Result"
            }
        }
        else {
            return "Search History"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        profileTVC.viewOnly = true
        profileTVC.viewType = ViewType.SendInterview
        
        if searchResults.count > 0 && indexPath.section == 0 {
            
            profileTVC.individualProfile = searchResults[indexPath.row]
            navigationController?.pushViewController(profileTVC, animated: true)
            
            // Add to previous searches
            self.profile.previousSearchCollection.add(name: searchResults[indexPath.row].name!, profession: searchResults[indexPath.row].profession!, contactEmail: searchResults[indexPath.row].contactEmail!, cKRecordName: searchResults[indexPath.row].cKRecordName!, searchDate: Date.init())
        }
        else {
            
            let individualProfileCKRecordName = profile.previousSearchCollection.previousSearches[indexPath.row].cKRecordName
            
            let individualProfile = IndividualProfile()
            individualProfile.forceFetch(with: individualProfileCKRecordName, completion: {
                
                // Check if profile was fetched successfully
                if individualProfile.cKRecordName != nil {
                    
                    self.profileTVC.individualProfile = individualProfile
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(self.profileTVC, animated: true)
                    }
                    
                    // Add to previous searches
                    self.profile.previousSearchCollection.add(name: individualProfile.name!, profession: individualProfile.profession!, contactEmail: individualProfile.contactEmail!, cKRecordName: individualProfile.cKRecordName!, searchDate: Date.init())
                }
                else { // Profile no longer exists
                    
                    // Remove from previous searches
                    self.profile.previousSearchCollection.removeSearch(cKRecordName: individualProfileCKRecordName)
                    
                    DispatchQueue.main.async {
                        self.alert("", message: "The profile no longer exists.")
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    // MARK: - Delegate Methods
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: false, completion: nil)
        searchBar.text?.removeAll()
        searchEmail = ""
        saveInvitationSubscription()
    }
}
