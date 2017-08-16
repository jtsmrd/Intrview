//
//  SpotlightVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/23/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit
import AVKit
import AVFoundation

class SpotlightVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SpotlightOverlayVCDelegate {

    // MARK: Outlets
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var desiredPositionTextField: CustomTextField!
    @IBOutlet weak var recordButton: CustomButton!
    @IBOutlet weak var viewButton: CustomButton!
    @IBOutlet weak var notesTextView: CustomTextView!
    
    // MARK: Constants
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let videoStore = VideoStore()
    
    // MARK: Variables
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var businessProfile: BusinessProfile!
    var currentFirstResponder: UIView!
    var imagePicker = UIImagePickerController()
    var spotlightOverlayVC = SpotlightOverlayVC()
    var spotlight: Spotlight!
    var sendBarButtonItem: UIBarButtonItem!
    var navToolBar: UIToolbar!
    
    // MARK: View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Send Spotlight"
        
        sendBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendButtonAction))
        sendBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = sendBarButtonItem
        
        infoLabel.text = "Record a video of yourself explaining your talents, skills, and why you should be hired. You can optionally include questions or notes to display while you record yourself for reference to points to talk about."
        
        navToolBar = createKeyboardToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If returning from viewing video, don't disable
        if spotlight.videoCKRecordName == nil {
            sendBarButtonItem.isEnabled = false
            viewButton.isEnabled = false
            viewButton.alpha = 0.5
        }
        
        if desiredPositionTextField.borderColor == Global.redColor {
            desiredPositionTextField.borderColor = UIColor.lightText
            desiredPositionTextField.setNeedsDisplay()
        }
    }

    @IBAction func recordButtonAction(_ sender: Any) {
        recordSpotlightVideo()
    }
    
    @IBAction func viewButtonAction(_ sender: Any) {
        viewSpotlightVideo()
    }
    
    @objc func backButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func sendButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        if isValid() {
            sendSpotlight()
        }
    }

    // MARK: Private Functions
    
    private func isValid() -> Bool {
        
        if (desiredPositionTextField.text?.isEmpty)! {
            
            desiredPositionTextField.borderColor = Global.redColor
            desiredPositionTextField.setNeedsDisplay()
            
            return false
        }
        
        return true
    }
    
    private func recordSpotlightVideo() {
        
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
            
            spotlightOverlayVC = SpotlightOverlayVC()
            spotlightOverlayVC.view.frame = imagePicker.view.frame
            spotlightOverlayVC.notes = notesTextView.text
            spotlightOverlayVC.delegate = self
            
            present(imagePicker, animated: true, completion: {
                self.imagePicker.cameraOverlayView = self.spotlightOverlayVC.view
            })
        }
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
    
    private func saveSpotlightVideo(videoURL: URL) {
        
        spotlight.saveVideo(videoURL: videoURL) {
            DispatchQueue.main.async {
                self.sendBarButtonItem.isEnabled = true
                self.viewButton.isEnabled = true
                self.viewButton.alpha = 1
            }
        }
    }
    
    private func sendSpotlight() {
        
        spotlight.businessProfileCKRecordName = self.businessProfile.cKRecordName
        spotlight.individualProfileCKRecordName = self.profile.individualProfile?.cKRecordName
        spotlight.jobTitle = desiredPositionTextField.text!
        spotlight.individualName = profile.individualProfile?.name
        spotlight.businessName = businessProfile.name
        spotlight.businessNewFlag = true
        spotlight.createDate = Date()
        
        spotlight.save {
            
            self.profile.individualProfile?.subscribeToSpotlightViews(spotlightCKRecordName: self.spotlight.cKRecordName!, businessName: self.businessProfile.name!)
            
            self.profile.individualProfile?.spotlightCollection.spotlights.append(self.spotlight)
            
            DispatchQueue.main.async {
                self.alert("Success", message: "Spotlight video sent!")
            }
        }
    }
    
    private func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentFirstResponder = textField
        
        textField.inputAccessoryView = navToolBar
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if desiredPositionTextField.borderColor == Global.redColor {
            desiredPositionTextField.borderColor = UIColor.lightText
            desiredPositionTextField.setNeedsDisplay()
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        textView.inputAccessoryView = navToolBar
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let existingText = textView.text else { return true }
        
        let newLength = existingText.characters.count + text.characters.count - range.length
        return newLength <= 400
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentFirstResponder = textView
    }
    
    // MARK: SpotlightOverlayVC Delegate Functions
    
    func recordButtonTapped(isRecording: Bool) {
        
        if !isRecording {
            imagePicker.startVideoCapture()
        }
        else {
            imagePicker.stopVideoCapture()
            dismiss(animated: true, completion: nil)
        }
    }
    
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Image Picker Delegate Functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let videoURL = info[UIImagePickerControllerMediaURL] as! URL
        saveSpotlightVideo(videoURL: videoURL)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    // MARK: - Keyboard toolbar
    
    @objc func doneAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
    }
    
    @objc func previousAction() {
        
        if let previousField = currentFirstResponder.superview!.viewWithTag(currentFirstResponder.tag - 100) {
            previousField.becomeFirstResponder()
        }
    }
    
    @objc func nextAction() {
        
        if let nextField = currentFirstResponder.superview!.viewWithTag(currentFirstResponder.tag + 100) {
            nextField.becomeFirstResponder()
        }
    }
    
    private func createKeyboardToolBar() -> UIToolbar {
        
        let keyboardToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        keyboardToolBar.barStyle = .default
        
        let previous = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(previousAction))
        previous.width = 50
        previous.tintColor = Global.greenColor
        
        let next = UIBarButtonItem(image: UIImage(named: "right_icon"), style: .plain, target: self, action: #selector(nextAction))
        next.width = 50
        next.tintColor = Global.greenColor
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        done.tintColor = Global.greenColor
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        keyboardToolBar.items = [previous, next, flexSpace, done]
        keyboardToolBar.sizeToFit()
        
        return keyboardToolBar
    }
}
