//
//  AddEditInterviewQuestionVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/18/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class AddEditInterviewQuestionVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var interviewQuestionTextView: UITextView!
    @IBOutlet weak var timeLimitTextField: UITextField!
    @IBOutlet weak var deleteButton: CustomButton!
    
    let pickerViewValues = [10, 20, 30, 45, 60]
    
    var interviewQuestion: InterviewQuestion!
    var interviewTemplate: InterviewTemplate!
    var currentFirstResponder: UIView!
    var navToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonAction))
        saveBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        if interviewQuestion != nil {
            
            if let question = interviewQuestion.question {
                interviewQuestionTextView.text = question
            }
            
            if let timeLimit = interviewQuestion.timeLimitInSeconds {
                timeLimitTextField.text = String(describing: timeLimit)
            }
        }
        else {
            interviewQuestionTextView.text = "Interview Question"
            deleteButton.isHidden = true
        }
        
        navToolBar = createKeyboardToolBar()
    }

    @objc func doneButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        if interviewQuestion != nil {
            
            interviewQuestion.question = interviewQuestionTextView.text
            interviewQuestion.timeLimitInSeconds = Int(timeLimitTextField.text!)
        }
        else {
            interviewQuestion = InterviewQuestion()
            interviewQuestion.question = interviewQuestionTextView.text
            interviewQuestion.timeLimitInSeconds = Int(timeLimitTextField.text!)
            
            interviewTemplate.interviewQuestions.append(interviewQuestion)
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let index = interviewTemplate.interviewQuestions.index { (question) -> Bool in
            question.question == self.interviewQuestion.question
        }
        
        if let questionIndex = index {
            interviewTemplate.interviewQuestions.remove(at: questionIndex)
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
        
        let numberPicker = UIPickerView()
        numberPicker.dataSource = self
        numberPicker.delegate = self
        textField.inputView = numberPicker
        
        if textField.text != "" {
            let index = pickerViewValues.index(of: Int(textField.text!)!)
            numberPicker.selectRow(index!, inComponent: 0, animated: false)
        }
        else {
            textField.text = String(pickerViewValues[0])
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        textView.inputAccessoryView = navToolBar
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let existingText = textView.text else { return true }
        
        let newLength = existingText.characters.count + text.characters.count - range.length
        return newLength <= 300
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentFirstResponder = textView
    }
    
    // MARK: - UIPickerView Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerViewValues[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeLimitTextField.text = String(pickerViewValues[row])
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
