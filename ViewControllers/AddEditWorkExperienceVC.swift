//
//  AddEditWorkExperienceVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class AddEditWorkExperienceVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var employerTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var deleteButton: CustomButton!
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var currentFirstResponder: UIView!
    var navToolBar: UIToolbar!
    var selectedDateTextField: UITextField!
    var workExperience: WorkExperience?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))
        saveBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        if workExperience != nil {
            jobTitleTextField.text = workExperience?.jobTitle
            employerTextField.text = workExperience?.employerName
            
            if let startDate = workExperience?.startDate {
                self.startDateTextField.text = Global.dateFormatter.string(from: startDate)
            }
            
            if let endDate = workExperience?.endDate {
                self.endDateTextField.text = Global.dateFormatter.string(from: endDate)
            }
        }
        else {
            deleteButton.isHidden = true
        }
        
        navToolBar = createKeyboardToolBar()
    }

    @objc func saveButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        if workExperience != nil {
            
            workExperience?.jobTitle = jobTitleTextField.text
            workExperience?.employerName = employerTextField.text
            workExperience?.startDate = Global.dateFormatter.date(from: startDateTextField.text!)
            workExperience?.endDate = Global.dateFormatter.date(from: endDateTextField.text!)
            profile.save()
        }
        else {
            workExperience = WorkExperience()
            workExperience?.jobTitle = jobTitleTextField.text
            workExperience?.employerName = employerTextField.text
            workExperience?.startDate = Global.dateFormatter.date(from: startDateTextField.text!)
            workExperience?.endDate = Global.dateFormatter.date(from: endDateTextField.text!)
            
            profile.individualProfile?.workExperienceCollection.append(workExperience!)
            profile.save()
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
        
        let index = profile.individualProfile?.workExperienceCollection.index(where: { (experience) -> Bool in
            
            experience.employerName == self.workExperience?.employerName && experience.jobTitle == self.workExperience?.jobTitle
        })
        
        if let experienceIndex = index {
            profile.individualProfile?.workExperienceCollection.remove(at: experienceIndex)
            profile.save()
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDateTextField.text = Global.dateFormatter.string(from: sender.date)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
        
        if textField.tag == 300 || textField.tag == 400 {
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            selectedDateTextField = textField
            if textField.text != "" {
                datePicker.date = Global.dateFormatter.date(from: textField.text!)!
            }
            datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        }
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
