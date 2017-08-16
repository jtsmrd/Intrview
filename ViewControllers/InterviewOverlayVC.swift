//
//  InterviewOverlayVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 3/5/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import UIKit

protocol InterviewOverlayVCDelegate {
    func didSkipQuestion(_ overlayView: InterviewOverlayVC, skippedQuestion: InterviewQuestion, skippedTime: Int)
    func interviewDidFinish(_ overlayView: InterviewOverlayVC)
}

class InterviewOverlayVC: UIViewController {

    // MARK: - Variables, Outlets, and Constants
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    var delegate: InterviewOverlayVCDelegate! = nil
    var counter = 0
    var timer = Timer()
    var interview: Interview!
    var interviewQuestions = [InterviewQuestion]()
    var currentQuestion: InterviewQuestion!
    var skippedQuestion: InterviewQuestion!
    var skippedTime = 0
    var playbackMode = false
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        
        interviewQuestions = interview.interviewTemplate.interviewQuestions
        
        if self.playbackMode {
            self.skipButton.isHidden = true
        }
        
        setupQuestions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        timer.invalidate()
        delegate.interviewDidFinish(self)
    }
    
    // MARK: - Actions
    
    @IBAction func skipAction(_ sender: UIButton) {
        
        timer.invalidate()
        skippedQuestion = currentQuestion
        skippedTime = counter + 1
        delegate.didSkipQuestion(self, skippedQuestion: skippedQuestion, skippedTime: skippedTime)
        nextQuestion()
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupQuestions() {
        
        sortInterviewQuestions()
        loadQuestion()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InterviewOverlayVC.updateTimeRemainingLabel), userInfo: nil, repeats: true)
        timer.fire()
    }

    fileprivate func nextQuestion() {
        
        if !interviewQuestions.isEmpty {
            loadQuestion()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InterviewOverlayVC.updateTimeRemainingLabel), userInfo: nil, repeats: true)
            timer.fire()
        }
        else {
            counter = 0
            timeRemainingLabel.text = String(counter)
            questionLabel.text = "Interview is over"
            delegate.interviewDidFinish(self)
        }
    }
    
    fileprivate func sortInterviewQuestions() {
        
        interviewQuestions.sort { (q1, q2) -> Bool in
            q1.displayOrder! > q2.displayOrder!
        }
    }
    
    fileprivate func loadQuestion() {
        
        currentQuestion = interviewQuestions.popLast()
        counter = currentQuestion.timeLimitInSeconds!
        questionLabel.text = currentQuestion.question
        timeRemainingLabel.text = String(counter)
    }
    
    // MARK: - Delegate Methods
    
    @objc func updateTimeRemainingLabel() {
        
        if counter == 0 {
            timer.invalidate()
            nextQuestion()
        }
        else {
            timeRemainingLabel.text = String(counter)
            counter -= 1
        }
    }
}
