//
//  BusinessSearchTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/3/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class BusinessSearchVC: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let profileTVC = ProfileTVC(nibName: "ProfileTVC", bundle: nil)
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var searchResults = [BusinessProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Search"
        
        navigationController?.navigationBar.barTintColor = Global.greenColor
        searchBar.tintColor = Global.greenColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    private func fetchCompaniesFromCloud(searchString: String) {
        
        searchResults.removeAll()
        
        let query = CKQuery(recordType: "BusinessProfile", predicate: NSPredicate(format: "searchName BEGINSWITH %@", searchString))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
            }
            else if let records = records {
                
                if !records.isEmpty {

                    for record in records {
                        self.searchResults.append(BusinessProfile(with: record))
                    }
                }
                else {
                    self.alert("", message: "No results found.")
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        
        tableView.reloadData()
        
        if let searchBarText = searchBar.text {
            let searchText = searchBarText.lowercased().replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            fetchCompaniesFromCloud(searchString: searchText)
        }
        
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    // MARK: - Table view data source

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
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchResultCell")
        
        if searchResults.count > 0 && indexPath.section == 0 {
            cell.textLabel?.text = searchResults[indexPath.row].name
            return cell
        }
        else {
            cell.textLabel?.text = profile.previousSearchCollection.previousSearches[indexPath.row].name
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        profileTVC.viewOnly = true
        profileTVC.viewType = ViewType.SendSpotlight
        
        if searchResults.count > 0 && indexPath.section == 0 {
            
            profileTVC.businessProfile = searchResults[indexPath.row]
            navigationController?.pushViewController(profileTVC, animated: true)
            
            // Add to previous searches
            self.profile.previousSearchCollection.add(name: searchResults[indexPath.row].name!, profession: "", contactEmail: searchResults[indexPath.row].contactEmail!, cKRecordName: searchResults[indexPath.row].cKRecordName!, searchDate: Date.init())
        }
        else {
            
            let businessProfileCKRecordName = profile.previousSearchCollection.previousSearches[indexPath.row].cKRecordName
            
            let businessProfile = BusinessProfile()
            businessProfile.forceFetch(with: businessProfileCKRecordName, completion: {
                
                // Check if profile was fetched successfully
                if businessProfile.cKRecordName != nil {
                    
                    self.profileTVC.businessProfile = businessProfile
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(self.profileTVC, animated: true)
                    }
                    
                    // Add to previous searches
                    self.profile.previousSearchCollection.add(name: businessProfile.name!, profession: "", contactEmail: businessProfile.contactEmail!, cKRecordName: businessProfile.cKRecordName!, searchDate: Date.init())
                }
                else { // Profile no longer exists
                    
                    // Remove from previous searches
                    self.profile.previousSearchCollection.removeSearch(cKRecordName: businessProfileCKRecordName)
                    
                    DispatchQueue.main.async {
                        self.alert("", message: "The profile no longer exists.")
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}
