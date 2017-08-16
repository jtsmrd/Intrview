//
//  SpotlightOverlayVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/3/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol SpotlightOverlayVCDelegate {
    func recordButtonTapped(isRecording: Bool)
    func cancelAction()
}

class SpotlightOverlayVC: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var questionNoteLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cancelButton: CustomButton!
    
    // MARK: Variables
    
    var delegate: SpotlightOverlayVCDelegate!
    var expireTimer = Timer()
    var counter = 60
    var notes: String!
    
    // MARK: View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timeRemainingLabel.text = String(counter)
        questionNoteLabel.text = notes
        
        counter = 60
        recordButton.setTitle("Record", for: .normal)
        cancelButton.isEnabled = true
        cancelButton.alpha = 1
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        delegate.cancelAction()
    }
    
    @IBAction func recordButtonAction(_ sender: Any) {
        
        if recordButton.tag == 1 {
            delegate.recordButtonTapped(isRecording: false)
            recordButton.tag = 2
            startTimer()
            recordButton.setTitle("Stop Recording", for: .normal)
            cancelButton.isEnabled = false
            cancelButton.alpha = 0.5
        }
        else {
            delegate.recordButtonTapped(isRecording: true)
            recordButton.tag = 1
            expireTimer.invalidate()
        }
    }
    
    private func startTimer() {
        
        expireTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SpotlightOverlayVC.updateTimeRemainingLabel), userInfo: nil, repeats: true)
        expireTimer.fire()
    }
    
    @objc func updateTimeRemainingLabel() {
        
        if counter == 0 {
            expireTimer.invalidate()
            delegate.recordButtonTapped(isRecording: true)
        }
        else {
            DispatchQueue.main.async {
                self.timeRemainingLabel.text = String(self.counter)
            }
            counter -= 1
        }
    }
}
