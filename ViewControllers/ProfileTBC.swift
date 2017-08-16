//
//  profileTBC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/24/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class ProfileTBC: UITabBarController, UITabBarControllerDelegate {

    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var profileTVC: ProfileTVC!
    var interviewsTVC: InterviewsTVC!
    var businessSearchVC: BusinessSearchVC!
    var spotlightsTVC: SpotlightsTVC!
    var interviewTemplateTVC: InterviewTemplateTVC!
    var individualSearchVC: IndividualSearchVC!
    var newInterviewCount: Int!
    var profileNavController: UINavigationController!
    var interviewTemplateNavController: UINavigationController!
    var interviewsNavController: UINavigationController!
    var individualSearchNavController: UINavigationController!
    var spotlightNavController: UINavigationController!
    var businessSearchNavController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newInterviewCount = 0
        tabBar.tintColor = Global.greenColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUpdates), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        profileTVC = ProfileTVC(nibName: "ProfileTVC", bundle: nil)
        profileTVC.viewType = ViewType.Edit
        let profileTabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile_icon"), selectedImage: UIImage(named: "profile_icon"))
        profileTVC.tabBarItem = profileTabBarItem
        
        profileNavController = UINavigationController()
        profileNavController.navigationBar.isTranslucent = false
        profileNavController.viewControllers = [profileTVC]
        
        
        interviewTemplateTVC = InterviewTemplateTVC(nibName: "InterviewTemplateTVC", bundle: nil)
        let interviewTemplateTabBarItem = UITabBarItem(title: "InterviewTypes", image: UIImage(named: "template_icon"), selectedImage: UIImage(named: "template_icon"))
        interviewTemplateTVC.tabBarItem = interviewTemplateTabBarItem
        
        interviewTemplateNavController = UINavigationController()
        interviewTemplateNavController.navigationBar.isTranslucent = false
        interviewTemplateNavController.viewControllers = [interviewTemplateTVC]
        
        
        interviewsTVC = InterviewsTVC(nibName: "InterviewsTVC", bundle: nil)
        let interviewsTabBarItem = UITabBarItem(title: "Interviews", image: UIImage(named: "interview_icon"), selectedImage: UIImage(named: "interview_icon"))
        interviewsTVC.tabBarItem = interviewsTabBarItem
        
        interviewsNavController = UINavigationController()
        interviewsNavController.navigationBar.isTranslucent = false
        interviewsNavController.viewControllers = [interviewsTVC]
        
        
        individualSearchVC = IndividualSearchVC(nibName: "IndividualSearchVC", bundle: nil)
        let individualSearchTabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search_icon"), selectedImage: UIImage(named: "search_icon"))
        individualSearchVC.tabBarItem = individualSearchTabBarItem
        
        individualSearchNavController = UINavigationController()
        individualSearchNavController.navigationBar.isTranslucent = false
        individualSearchNavController.viewControllers = [individualSearchVC]
        
        
        spotlightsTVC = SpotlightsTVC(nibName: "SpotlightsTVC", bundle: nil)
        let spotlightTabBarItem = UITabBarItem(title: "Spotlight", image: UIImage(named: "spotlight_icon"), selectedImage: UIImage(named: "spotlight_icon"))
        spotlightsTVC.tabBarItem = spotlightTabBarItem
        
        spotlightNavController = UINavigationController()
        spotlightNavController.navigationBar.isTranslucent = false
        spotlightNavController.viewControllers = [spotlightsTVC]
        
        
        businessSearchVC = BusinessSearchVC(nibName: "BusinessSearchVC", bundle: nil)
        let businessSearchTabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search_icon"), selectedImage: UIImage(named: "search_icon"))
        businessSearchVC.tabBarItem = businessSearchTabBarItem
        
        businessSearchNavController = UINavigationController()
        businessSearchNavController.navigationBar.isTranslucent = false
        businessSearchNavController.viewControllers = [businessSearchVC]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch profile.profileType! {
            
        case .Business:
            
            viewControllers = [interviewsNavController, interviewTemplateNavController, individualSearchNavController, spotlightNavController, profileNavController]
            
        case .Individual:
            
            viewControllers = [interviewsNavController, businessSearchNavController, spotlightNavController, profileNavController]
        }
        
        if !profile.exists {
            
            // Set to profile tab
            self.selectedViewController = profileNavController
        }
    }
    
    @objc func fetchUpdates() {
        
        if profile.exists {
            
            switch profile.profileType! {
            case .Business:
                
                profile.businessProfile?.interviewCollection.fetchAllInterviews(with: profile.cKRecordName!, profileType: .Business, completion: {
                    
                    let newInterviewCount = self.profile.businessProfile?.interviewCollection.interviews.filter({ (interview) -> Bool in
                        interview.businessNewFlag == true
                    }).count
                    
                    if let count = newInterviewCount {
                        if count > 0 {
                            DispatchQueue.main.async {
                                self.interviewsTVC.tabBarItem.badgeValue = "\(count)"
                                self.interviewsTVC.sortAndRefreshInterviews()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.interviewsTVC.tabBarItem.badgeValue = nil
                            }
                        }
                    }
                })
                
                profile.businessProfile?.spotlightCollection.fetchAllSpotlights(with: profile.cKRecordName!, profileType: .Business, completion: {
                    
                    let newSpotlightCount = self.profile.businessProfile?.spotlightCollection.spotlights.filter({ (spotlight) -> Bool in
                        spotlight.businessNewFlag == true
                    }).count
                    
                    if let count = newSpotlightCount {
                        if count > 0 {
                            DispatchQueue.main.async {
                                self.spotlightsTVC.tabBarItem.badgeValue = "\(count)"
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.spotlightsTVC.tabBarItem.badgeValue = nil
                            }
                        }
                    }
                })
                
            case .Individual:
                
                profile.individualProfile?.interviewCollection.fetchAllInterviews(with: profile.cKRecordName!, profileType: .Individual, completion: {
                    
                    let newInterviewCount = self.profile.individualProfile?.interviewCollection.interviews.filter({ (interview) -> Bool in
                        interview.individualNewFlag == true
                    }).count
                    
                    if let count = newInterviewCount {
                        if count > 0 {
                            DispatchQueue.main.async {
                                self.interviewsTVC.tabBarItem.badgeValue = "\(count)"
                                self.interviewsTVC.sortAndRefreshInterviews()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.interviewsTVC.tabBarItem.badgeValue = nil
                            }
                        }
                    }
                })
                
                profile.individualProfile?.spotlightCollection.fetchAllSpotlights(with: profile.cKRecordName!, profileType: .Individual, completion: {
                    
                    let newSpotlightCount = self.profile.individualProfile?.spotlightCollection.spotlights.filter({ (spotlight) -> Bool in
                        spotlight.individualNewFlag == true
                    }).count
                    
                    if let count = newSpotlightCount {
                        if count > 0 {
                            DispatchQueue.main.async {
                                self.spotlightsTVC.tabBarItem.badgeValue = "\(count)"
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.spotlightsTVC.tabBarItem.badgeValue = nil
                            }
                        }
                    }
                })
            }
        }
    }
}
