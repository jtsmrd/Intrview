//
//  BusinessInterviewDetailVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/25/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class BusinessInterviewDetailVC: UIViewController, InterviewOverlayVCDelegate, AVPlayerViewControllerDelegate {

    // MARK: - Variables, Outlets, and Constants
    
    @IBOutlet weak var individualNameLabel: UILabel!
    @IBOutlet weak var viewProfileButton: CustomButton!
    @IBOutlet weak var interviewTypeLabel: UILabel!
    @IBOutlet weak var viewTypeButton: CustomButton!
    @IBOutlet weak var deleteInterviewButton: CustomButton!
    @IBOutlet weak var interviewVideoButton: CustomButton!
    @IBOutlet weak var requestDateLabel: UILabel!
    @IBOutlet weak var expireLabel: UILabel!
    @IBOutlet weak var completeDateLabel: UILabel!
    
    let videoStore = (UIApplication.shared.delegate as! AppDelegate).videoStore
    let profileTVC = ProfileTVC(nibName: "ProfileTVC", bundle: nil)
    
    var interviewOverlayVC: InterviewOverlayVC!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var interview: Interview!
    var individualProfile = IndividualProfile()
    var backButton: UIBarButtonItem!
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Interview Details"
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
        backButton = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interview.interviewTemplate.updateWithInterviewDetailsDictionaryString(interview.interviewDetailsData!)
        
        individualProfile.forceFetch(with: interview.individualProfileCKRecordName!) {
            DispatchQueue.main.async {
                self.individualNameLabel.text = self.individualProfile.name
            }
        }
        
        individualNameLabel.text = interview.individualName
        interviewTypeLabel.text = interview.interviewTitle
        requestDateLabel.text = "Requested: \(Global.dateFormatter.string(from: interview.createDate!))"
        
        if interview.daysUntilExpired > 0 {
            expireLabel.text = "Expires in \(interview.daysUntilExpired) days"
        }
        else {
            expireLabel.text = "Expires in \(interview.hoursUntilExpired) hours"
        }
        
        switch interview.interviewStatus! {
            
        case InterviewStatus.Pending.rawValue:
            interviewVideoButton.alpha = 0.5
            interviewVideoButton.isEnabled = false
            
        case InterviewStatus.Complete.rawValue:
            
            // Fetch the interview video
            if let videoCKRecordName = interview.videoCKRecordName {
                if let videoKey = interview.videoKey {
                    if let _ = videoStore.videoForKey(videoKey) {
                    }
                    else {
                        interview.fetchVideo(videoCKRecordName: videoCKRecordName, completion: {
                        })
                    }
                    interviewVideoButton.setTitle("View", for: UIControlState())
                }
            }
            
            if let completeDate = interview.completeDate {
                completeDateLabel.text = "Completed: \(Global.dateFormatter.string(from: completeDate))"
            }
            
        case InterviewStatus.Declined.rawValue:
            
            interviewVideoButton.setTitle("Declined", for: UIControlState())
            interviewVideoButton.alpha = 0.5
            interviewVideoButton.isEnabled = false
        default:
            break
        }
        
        // Only allow user to delete Interview if it was declined or has been viewed atleast once
        if interview.interviewStatus! == InterviewStatus.Declined.rawValue || interview.viewCount > 0 {
            deleteInterviewButton.isHidden = false
        }
        else {
            deleteInterviewButton.isHidden = true
        }
        
        if interview.businessNewFlag == true {
            interview.businessNewFlag = false
            interview.save {
                
            }
            
            let index = profile.businessProfile?.interviewCollection.interviews.index(where: { (interview) -> Bool in
                interview.cKRecordName == self.interview.cKRecordName
            })
            
            if let interviewIndex = index {
                profile.businessProfile?.interviewCollection.interviews[interviewIndex].businessNewFlag = false
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func backButtonAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func interviewVideoButtonAction() {
        
        viewInterview()
        interview.viewCount += 1
        interview.individualNewFlag = true
        interview.save {
            
        }
    }
    
    @IBAction func deleteInterviewButtonAction() {
        deleteInterview()
    }
    
    @IBAction func viewProfileButtonAction(_ sender: Any) {
        
        profileTVC.viewOnly = true
        profileTVC.viewType = ViewType.ViewOnly
        profileTVC.individualProfile = individualProfile
        
        navigationController?.pushViewController(profileTVC, animated: true)
    }
    
    @IBAction func viewTypeButtonAction(_ sender: Any) {
        
        let profileEditTVC = ProfileEditTVC(nibName: "ProfileEditTVC", bundle: nil)
        profileEditTVC.addSectionType = AddSectionType.InterviewQuestion
        profileEditTVC.interviewTemplate = self.interview.interviewTemplate
        profileEditTVC.viewOnly = true
        
        navigationController?.pushViewController(profileEditTVC, animated: true)
    }
    
    // MARK: - Private Methods
    
    fileprivate func viewInterview() {
        interviewOverlayVC = InterviewOverlayVC()
        interviewOverlayVC.delegate = self
        interviewOverlayVC.interview = interview
        interviewOverlayVC.playbackMode = true
        interviewOverlayVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        let videoPlayer = AVPlayerViewController()
        videoPlayer.showsPlaybackControls = true
        videoPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPlayer.player = AVPlayer(url: videoStore.videoURLForKey(interview.videoKey!))
        
        present(videoPlayer, animated: true, completion: {
            videoPlayer.contentOverlayView?.addSubview(self.interviewOverlayVC.view)
            videoPlayer.player?.play()
        })
    }
    
    fileprivate func removeInterviewSubscription(_ interviewCKRecordName: String) {
//        var interviewSubscriptions = UserDefaults.standard.dictionary(forKey: "InterviewSubscriptions")
//        let subscriptionIDs = interviewSubscriptions!["\(interviewCKRecordName)"] as? [String]
//        
//        for subscriptionID in subscriptionIDs! {
//            CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: subscriptionID) { (str, error) in
//                if let error = error {
//                    Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
//                }
//            }
//        }
    }
    
    private func deleteInterview() {
        
        let alertController = UIAlertController(title: "Delete Confirmation", message: "Are you sure you want to delete this interview?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            if self.interview.individualDeleteFlag {
                self.interview.delete()
            }
            else {
                self.interview.businessDeleteFlag = true
                self.interview.save {
                    
                }
            }
            
            let index = self.profile.businessProfile?.interviewCollection.interviews.index(where: { (interview) -> Bool in
                interview.cKRecordName == self.interview.cKRecordName
            })
            
            if let interviewIndex = index {
                self.profile.businessProfile?.interviewCollection.interviews.remove(at: interviewIndex)
            }
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: Delegate Methods
    
    func didSkipQuestion(_ overlayView: InterviewOverlayVC, skippedQuestion: InterviewQuestion, skippedTime: Int) {
        
    }
    
    func interviewDidFinish(_ overlayView: InterviewOverlayVC) {
        overlayView.dismiss(animated: true, completion: nil)
    }

}
