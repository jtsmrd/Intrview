//
//  SpotlightDetailVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/24/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SpotlightDetailVC: UIViewController {

    @IBOutlet weak var desiredPositionLabel: UILabel!
    @IBOutlet weak var profileTypeLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var viewProfileButton: CustomButton!
    @IBOutlet weak var viewSpotlightButton: CustomButton!
    @IBOutlet weak var deleteButton: CustomButton!
    @IBOutlet weak var expireLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    let videoStore = VideoStore()
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var spotlight: Spotlight!
    var businessProfile: BusinessProfile!
    var individualProfile: IndividualProfile!
    var profileTVC: ProfileTVC!
    var delegate: SpotlightsTVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileTVC = ProfileTVC(nibName: "ProfileTVC", bundle: nil)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Spotlight Details"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        desiredPositionLabel.text = self.spotlight.jobTitle!
        viewProfileButton.isEnabled = false
        viewProfileButton.alpha = 0.5
        viewSpotlightButton.isEnabled = false
        viewSpotlightButton.alpha = 0.5
        
        if spotlight.daysUntilExpired > 0 {
            expireLabel.text = "Expires in \(spotlight.daysUntilExpired) days"
        }
        else {
            expireLabel.text = "Expires in \(spotlight.hoursUntilExpired) hours"
        }
        
        viewsLabel.text = "Views: \(spotlight.viewCount)"
        
        switch profile.profileType! {
            
        case .Business:
            
            profileTypeLabel.text = "Profile"
            profileNameLabel.text = spotlight.individualName!
            
            if spotlight.viewCount == 0 {
                deleteButton.isEnabled = false
                deleteButton.alpha = 0.5
            }
            
            if individualProfile == nil {
                individualProfile = IndividualProfile()
                individualProfile.forceFetch(with: spotlight.individualProfileCKRecordName!, completion: {
                    
                    DispatchQueue.main.async {
                        self.viewProfileButton.isEnabled = true
                        self.viewProfileButton.alpha = 1
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    self.viewProfileButton.isEnabled = true
                    self.viewProfileButton.alpha = 1
                }
            }
            
        case .Individual:
            
            profileTypeLabel.text = "Company"
            profileNameLabel.text = spotlight.businessName!
            
            if businessProfile == nil {
                businessProfile = BusinessProfile()
                businessProfile.forceFetch(with: spotlight.businessProfileCKRecordName!, completion: {
                    
                    DispatchQueue.main.async {
                        self.viewProfileButton.isEnabled = true
                        self.viewProfileButton.alpha = 1
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    self.viewProfileButton.isEnabled = true
                    self.viewProfileButton.alpha = 1
                }
            }
            
            if spotlight.individualNewFlag == true {
                spotlight.individualNewFlag = false
                spotlight.save {
                    
                }
                
                let index = profile.individualProfile?.spotlightCollection.spotlights.index(where: { (spotlight) -> Bool in
                    spotlight.cKRecordName == self.spotlight.cKRecordName
                })
                
                if let spotlightIndex = index {
                    profile.individualProfile?.spotlightCollection.spotlights[spotlightIndex].individualNewFlag = false
                    delegate.spotlightDataModified()
                }
            }
        }
        
        if spotlight.videoKey == nil {
            spotlight.fetchVideo(videoCKRecordName: spotlight.videoCKRecordName!) {
                
                DispatchQueue.main.async {
                    self.viewSpotlightButton.isEnabled = true
                    self.viewSpotlightButton.alpha = 1
                }
            }
        }
        else {
            DispatchQueue.main.async {
                self.viewSpotlightButton.isEnabled = true
                self.viewSpotlightButton.alpha = 1
            }
        }
        
        //        if profile.profileType! == ProfileType.Business {
        //            profile.businessProfile?.addSpotlightCKRecordName(spotlightCKRecordName: self.spotlight.cKRecordName!)
        //        }
    }
    
    @objc func backButtonAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func viewProfileButtonAction(_ sender: Any) {
        
        profileTVC.viewType = ViewType.ViewOnly
        profileTVC.viewOnly = true
        
        switch profile.profileType! {
        case .Business:
            profileTVC.individualProfile = individualProfile
        case .Individual:
            profileTVC.businessProfile = businessProfile
        }
        
        navigationController?.pushViewController(profileTVC, animated: true)
    }
    
    @IBAction func viewSpotlightButtonAction(_ sender: Any) {
        
        switch profile.profileType! {
        case .Business:
            viewSpotlightVideo()
            
            deleteButton.isEnabled = true
            deleteButton.alpha = 1.0
            
            if spotlight.businessNewFlag == true {
                spotlight.businessNewFlag = false
                
                let index = profile.businessProfile?.spotlightCollection.spotlights.index(where: { (spotlight) -> Bool in
                    spotlight.cKRecordName == self.spotlight.cKRecordName
                })
                
                if let spotlightIndex = index {
                    profile.businessProfile?.spotlightCollection.spotlights[spotlightIndex].businessNewFlag = false
                    delegate.spotlightDataModified()
                }
            }
            
            spotlight.viewCount += 1
            spotlight.individualNewFlag = true
            spotlight.save {
                
            }
            
        case .Individual:
            viewSpotlightVideo()
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Delete Spotlight?", message: "Are you sure you want to delete this Spotlight?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            switch self.profile.profileType! {
                
            case .Business:
                
                if self.spotlight.individualDeleteFlag {
                    self.spotlight.delete()
                }
                else {
                    self.spotlight.businessDeleteFlag = true
                    self.spotlight.save {
                        
                    }
                }
                
                let index = self.profile.businessProfile?.spotlightCollection.spotlights.index(where: { (spotlight) -> Bool in
                    
                    spotlight.cKRecordName == self.spotlight.cKRecordName
                })
                
                if let spotlightIndex = index {
                    self.profile.businessProfile?.spotlightCollection.spotlights.remove(at: spotlightIndex)
                    self.delegate.spotlightDataModified()
                }
                
            case .Individual:
                
                if self.spotlight.businessDeleteFlag {
                    self.spotlight.delete()
                }
                else {
                    self.spotlight.individualDeleteFlag = true
                    self.spotlight.save {
                        
                    }
                }
                
                let index = self.profile.individualProfile?.spotlightCollection.spotlights.index(where: { (spotlight) -> Bool in
                    
                    spotlight.cKRecordName == self.spotlight.cKRecordName
                })
                
                if let spotlightIndex = index {
                    self.profile.individualProfile?.spotlightCollection.spotlights.remove(at: spotlightIndex)
                    self.delegate.spotlightDataModified()
                }
            }
            
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func viewSpotlightVideo() {
        
        if let videoKey = spotlight.videoKey {
            let videoPlayer = AVPlayerViewController()
            videoPlayer.showsPlaybackControls = true
            videoPlayer.modalPresentationStyle = .fullScreen
            videoPlayer.player = AVPlayer(url: videoStore.videoURLForKey(videoKey))
            
            present(videoPlayer, animated: true, completion: {
                videoPlayer.player?.play()
            })
        }
    }
}
