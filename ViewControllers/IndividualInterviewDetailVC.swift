//
//  IndividualInterviewDetailVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/24/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class IndividualInterviewDetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, InterviewOverlayVCDelegate {

    // MARK: - Variables, Outlets, and Constants
    
    @IBOutlet weak var interviewerLabel: UILabel!
    @IBOutlet weak var viewProfileButton: CustomButton!
    @IBOutlet weak var interviewTitleLabel: UILabel!
    @IBOutlet weak var interviewDescriptionLabel: UILabel!
    @IBOutlet weak var requestedDateLabel: UILabel!
    @IBOutlet weak var completedDateLabel: UILabel!
    @IBOutlet weak var declineInterviewButton: CustomButton!
    @IBOutlet weak var beginInterviewButton: CustomButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var expireLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    let profileTVC = ProfileTVC(nibName: "ProfileTVC", bundle: nil)
    
    var interviewQuestions = [InterviewQuestion]()
    var interviewQuestionsSkipped: Bool = false
    var imagePicker = UIImagePickerController()
    var interviewOverlayVC = InterviewOverlayVC()
    var videoStore = (UIApplication.shared.delegate as! AppDelegate).videoStore
    var cameraAccessGranted = false
    var micAccessGranted = false
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var interview: Interview!
    var businessProfile = BusinessProfile()
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Interview Details"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        businessProfile.forceFetch(with: interview.businessProfileCKRecordName!) {
            DispatchQueue.main.async {
                self.viewProfileButton.isEnabled = true
            }
        }
        
        setupView()
        
        interviewTitleLabel.text = interview.interviewTitle
        interviewDescriptionLabel.text = interview.interviewDescription
        requestedDateLabel.text = "Requested: \(Global.dateFormatter.string(from: interview.createDate!))"
        interviewerLabel.text = interview.businessName
        
        if interview.daysUntilExpired > 0 {
            expireLabel.text = "Expires in \(interview.daysUntilExpired) days"
        }
        else {
            expireLabel.text = "Expires in \(interview.hoursUntilExpired) hours"
        }

        interviewQuestions = interview.interviewTemplate.interviewQuestions
        
        if interview.interviewStatus == InterviewStatus.Declined.rawValue || interview.interviewStatus == InterviewStatus.Complete.rawValue {
            declineInterviewButton.tag = 2
        }
        
//        self.profile.individualProfile?.addInterviewCKRecordName(interviewCKRecordName: interview.cKRecordName!)
        
        if interview.individualNewFlag == true {
            interview.individualNewFlag = false
            interview.save {
                
            }
            
            let index = profile.individualProfile?.interviewCollection.interviews.index(where: { (interview) -> Bool in
                interview.cKRecordName == self.interview.cKRecordName
            })
            
            if let interviewIndex = index {
                profile.individualProfile?.interviewCollection.interviews[interviewIndex].individualNewFlag = false
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func backButtonAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func beginInterviewButtonAction() {
        
        if interview.interviewStatus == InterviewStatus.Pending.rawValue {
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) == .authorized && AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
                showStartInterviewAlert()
            }
            else {
                let alertController = UIAlertController(title: "Allow Access", message: "Allow camera and microphone access to start interviewing", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.promptCameraAndMicAccess()
                })
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
        else if interview.interviewStatus == InterviewStatus.Complete.rawValue {
            self.playInterview()
        }
    }
    
    @IBAction func declineInterviewButtonAction() {
        
        if declineInterviewButton.tag == 1 {
            declineInterview()
            declineInterviewButton.tag = 2
        }
        else {
            deleteInterview()
        }
    }
    
    @IBAction func viewProfileButtonAction(_ sender: Any) {
        
        profileTVC.viewOnly = true
        profileTVC.viewType = ViewType.ViewOnly
        profileTVC.businessProfile = self.businessProfile
        
        navigationController?.pushViewController(profileTVC, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func showStartInterviewAlert() {
        
        let alertController = UIAlertController(title: "Begin Interview", message: "Are you ready to start?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Not yet.", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        let beginAction = UIAlertAction(title: "Lets do this!", style: .default) { (action) in
            self.startInterview()
        }
        alertController.addAction(beginAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func promptCameraAndMicAccess() {
        isCameraAccessGranted { (granted) in
            self.cameraAccessGranted = granted
        }
        isMicAccessGranted { (granted) in
            self.micAccessGranted = granted
        }
    }
    
    private func isMicAccessGranted(_ completion: @escaping ((Bool) -> Void)) {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in
                if granted {
                    completion(true)
                }
                else {
                    completion(false)
                }
            })
        }
        completion(true)
    }
    
    private func isCameraAccessGranted(_ completion: @escaping ((Bool) -> Void)) {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                if granted {
                    completion(true)
                }
                else {
                    completion(false)
                }
            })
        }
        completion(true)
    }
    
    private func setupView() {
        
        if interview.interviewStatus == InterviewStatus.Complete.rawValue {
            
            beginInterviewButton.setTitle("View", for: UIControlState())
            declineInterviewButton.setTitle("Delete", for: UIControlState())
            completedDateLabel.text = "Completed: \(Global.dateFormatter.string(from: interview.completeDate!))"
            viewsLabel.text = "Views: \(interview.viewCount)"
        }
        else if interview.interviewStatus == InterviewStatus.Declined.rawValue {
            
            beginInterviewButton.setTitle("Declined", for: UIControlState())
            beginInterviewButton.isEnabled = false
            beginInterviewButton.alpha = 0.5
            declineInterviewButton.setTitle("Delete", for: UIControlState())
        }
    }
    
    private func startInterview() {
        
        if UIImagePickerController.availableCaptureModes(for: .front) != nil {
            imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.cameraCaptureMode = .video
            imagePicker.showsCameraControls = false
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.cameraDevice = .front
            
            interviewOverlayVC.view.frame = imagePicker.view.frame
            interviewOverlayVC.delegate = self
            interviewOverlayVC.interview = self.interview
            interviewOverlayVC.playbackMode = false
            
            present(imagePicker, animated: true, completion: {
                self.imagePicker.startVideoCapture()
                self.imagePicker.cameraOverlayView = self.interviewOverlayVC.view
            })
        }
        else {
            alert("Incompatible Device", message: "A device with a front facing camera is required to complete interviews.")
        }
    }
    
    private func saveInterview(videoURL: URL) {
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        self.interview.saveVideo(videoURL: videoURL) {
            
            self.interview.interviewStatus = InterviewStatus.Complete.rawValue
            self.interview.completeDate = Date()
            self.interview.businessNewFlag = true
            
            let index = self.profile.individualProfile?.interviewCollection.interviews.index(where: { (interview) -> Bool in
                interview.cKRecordName == self.interview.cKRecordName
            })
            
            if let interviewIndex = index {
                self.profile.individualProfile?.interviewCollection.interviews[interviewIndex].interviewStatus = InterviewStatus.Complete.rawValue
                self.profile.individualProfile?.interviewCollection.interviews[interviewIndex].completeDate = self.interview.completeDate
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.setupView()
            }
            
            if self.interviewQuestionsSkipped {
                self.interview.createInterviewDataString()
            }
            
            self.interview.save(completion: {
                
            })
        }
    }
    
    private func createInterviewQuestionsData() -> String {
        
        var interviewQuestionsDictionary = [String: [String: AnyObject]]()
        
        for i in 0..<interviewQuestions.count{
            interviewQuestionsDictionary["\(i)"] = [String: AnyObject]()
            interviewQuestionsDictionary["\(i)"]!["Question"] = interviewQuestions[i].question as AnyObject?
            interviewQuestionsDictionary["\(i)"]!["TimeLimit"] = interviewQuestions[i].timeLimitInSeconds as AnyObject?
            interviewQuestionsDictionary["\(i)"]!["DisplayOrder"] = interviewQuestions[i].displayOrder as AnyObject?
        }
        let dictionaryString = Global.convertDictionaryToString(interviewQuestionsDictionary as [String : AnyObject])
        return dictionaryString
    }
    
    private func playInterview() {
        
        let videoPlayer = AVPlayerViewController()
        videoPlayer.showsPlaybackControls = true
        videoPlayer.modalPresentationStyle = .fullScreen
        videoPlayer.player = AVPlayer(url: videoStore.videoURLForKey(interview.videoKey!))
        
        present(videoPlayer, animated: true, completion: {
            videoPlayer.player?.play()
        })
    }
    
    private func declineInterview() {
        
        let alertController = UIAlertController(title: "Decline Interview", message: "Are you sure you want to decline this Interview?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let declineAction = UIAlertAction(title: "Decline", style: .destructive) { (action) in
            
            self.interview.interviewStatus = InterviewStatus.Declined.rawValue
            self.interview.businessNewFlag = true
            self.interview.save {
                
            }
            
            DispatchQueue.main.async {
                self.declineInterviewButton.setTitle("Delete", for: .normal)
                self.beginInterviewButton.setTitle("Declined", for: UIControlState())
                self.beginInterviewButton.isEnabled = false
                self.beginInterviewButton.alpha = 0.5
            }
        }
        alertController.addAction(declineAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteInterview() {
        
        let alertController = UIAlertController(title: "Delete Interview", message: "Are you sure you want to delete this Interview?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let declineAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // Remove interviewCKRecordName from storeed recordNames
//            self.profile.individualProfile?.removeInterviewCKRecordName(interviewCKRecordName: self.interview.cKRecordName!)
            
            if self.interview.businessDeleteFlag {
                self.interview.delete()
            }
            else {
                self.interview.individualDeleteFlag = true
                self.interview.save {
                    
                }
            }
            
            let index = self.profile.individualProfile?.interviewCollection.interviews.index(where: { (interview) -> Bool in
                interview.cKRecordName == self.interview.cKRecordName
            })
            
            if let interviewIndex = index {
                self.profile.individualProfile?.interviewCollection.interviews.remove(at: interviewIndex)
            }
            
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(declineAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Delegate methods
    
    func didSkipQuestion(_ overlayView: InterviewOverlayVC, skippedQuestion: InterviewQuestion, skippedTime: Int) {
        
        interviewQuestionsSkipped = true
        let index = self.interview.interviewTemplate.interviewQuestions.index { (question) -> Bool in
            question.question == skippedQuestion.question
        }
        
        self.interview.interviewTemplate.interviewQuestions[index!].timeLimitInSeconds = skippedQuestion.timeLimitInSeconds! - skippedTime
    }
    
    func interviewDidFinish(_ overlayView: InterviewOverlayVC) {
        
        if !overlayView.playbackMode {
            imagePicker.stopVideoCapture()
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let videoURL = info[UIImagePickerControllerMediaURL] as! URL
        saveInterview(videoURL: videoURL)
        
        dismiss(animated: true, completion: nil)
    }
}
