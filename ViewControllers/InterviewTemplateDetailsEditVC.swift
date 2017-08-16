//
//  InterviewTemplateDetailsEditVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/18/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class InterviewTemplateDetailsEditVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var interviewTitleTextField: UITextField!
    @IBOutlet weak var interviewDescriptionTextView: UITextView!
    
    var interviewTemplate: InterviewTemplate!
    var currentFirstResponder: UIView!
    var navToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonAction))
        doneBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        if let interviewTitle = interviewTemplate.jobTitle {
            self.interviewTitleTextField.text = interviewTitle
        }
        
        if let jobDescription = interviewTemplate.jobDescription {
            self.interviewDescriptionTextView.text = jobDescription
        }
        else {
            self.interviewDescriptionTextView.text = "Interview Description"
        }
        
        navToolBar = createKeyboardToolBar()
    }
    
    @objc func doneButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        interviewTemplate.jobTitle = interviewTitleTextField.text
        interviewTemplate.jobDescription = interviewDescriptionTextView.text
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        textView.inputAccessoryView = navToolBar
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let existingText = textView.text else { return true }
        
        let newLength = existingText.characters.count + text.characters.count - range.length
        return newLength <= 500
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentFirstResponder = textView
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
    
    fileprivate func createKeyboardToolBar() -> UIToolbar {
        
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
