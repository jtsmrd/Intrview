//
//  SpotlightsTVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/24/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol SpotlightsTVCDelegate {
    func spotlightDataModified()
}

class SpotlightsTVC: UITableViewController, SpotlightsTVCDelegate {
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var spotlights = [Spotlight]()
    var spotlightDetailVC: SpotlightDetailVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spotlightDetailVC = SpotlightDetailVC(nibName: "SpotlightDetailVC", bundle: nil)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Spotlights"
        
        tableView.register(UINib(nibName: "SpotlightCell", bundle: nil), forCellReuseIdentifier: "SpotlightCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch profile.profileType! {
            
        case .Business:
            
            self.spotlights = (self.profile.businessProfile?.spotlightCollection.spotlights)!
            
            let newSpotlightCount = self.spotlights.filter({ (spotlight) -> Bool in
                spotlight.businessNewFlag == true
            }).count
            
            if newSpotlightCount > 0 {
                DispatchQueue.main.async {
                    self.tabBarItem.badgeValue = "\(newSpotlightCount)"
                }
            }
            else {
                DispatchQueue.main.async {
                    self.tabBarItem.badgeValue = nil
                }
            }
            
        case .Individual:
            
            self.spotlights = (self.profile.individualProfile?.spotlightCollection.spotlights)!
            
            let newSpotlightCount = self.spotlights.filter({ (spotlight) -> Bool in
                spotlight.individualNewFlag == true
            }).count
            
            if newSpotlightCount > 0 {
                DispatchQueue.main.async {
                    self.tabBarItem.badgeValue = "\(newSpotlightCount)"
                }
            }
            else {
                DispatchQueue.main.async {
                    self.tabBarItem.badgeValue = nil
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func spotlightDataModified() {
        
        switch profile.profileType! {
        case .Business:
            self.spotlights = (self.profile.businessProfile?.spotlightCollection.spotlights)!
        case .Individual:
            self.spotlights = (self.profile.individualProfile?.spotlightCollection.spotlights)!
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if spotlights.isEmpty {
            return 1
        }
        else {
            return spotlights.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spotlightCell = tableView.dequeueReusableCell(withIdentifier: "SpotlightCell", for: indexPath) as! SpotlightCell
        let noDataCell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
        
        switch profile.profileType! {
            
        case .Business:
            
            if !spotlights.isEmpty {
                
                spotlightCell.configureCell(spotlight: spotlights[indexPath.row], profileName: spotlights[indexPath.row].individualName!, isNew: spotlights[indexPath.row].businessNewFlag)
                return spotlightCell
            }
            else {
                noDataCell.textLabel?.text = "No Spotlights Yet"
                noDataCell.textLabel?.textColor = Global.grayColor
                noDataCell.textLabel?.textAlignment = .center
                return noDataCell
            }
            
        case .Individual:

            if !spotlights.isEmpty {
                
                spotlightCell.configureCell(spotlight: spotlights[indexPath.row], profileName: spotlights[indexPath.row].businessName!, isNew: spotlights[indexPath.row].individualNewFlag)
                return spotlightCell
            }
            else {
                noDataCell.textLabel?.text = "Search for a company to send a Spotlight"
                noDataCell.textLabel?.textColor = Global.grayColor
                noDataCell.textLabel?.textAlignment = .center
                return noDataCell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSpotlight = spotlights[indexPath.row]
        spotlightDetailVC.spotlight = selectedSpotlight
        spotlightDetailVC.delegate = self
        navigationController?.pushViewController(spotlightDetailVC, animated: true)
    }    
}
