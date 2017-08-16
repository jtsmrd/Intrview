//
//  AddEditEducationVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class AddEditEducationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var degreeEarnedTextField: UITextField!
    @IBOutlet weak var schoolNameTextField: UITextField!
    @IBOutlet weak var schoolLocationTextField: UITextField!
    @IBOutlet weak var deleteButton: CustomButton!
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var currentFirstResponder: UIView!
    var navToolBar: UIToolbar!
    var education: Education?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))
        saveBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        if education != nil {
            degreeEarnedTextField.text = education?.degreeEarned
            schoolNameTextField.text = education?.schoolName
            schoolLocationTextField.text = education?.schoolLocation
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
        
        if education != nil {
            education?.degreeEarned = degreeEarnedTextField.text
            education?.schoolName = schoolNameTextField.text
            education?.schoolLocation = schoolLocationTextField.text
            profile.save()
        }
        else {
            education = Education()
            education?.degreeEarned = degreeEarnedTextField.text
            education?.schoolName = schoolNameTextField.text
            education?.schoolLocation = schoolLocationTextField.text
            
            profile.individualProfile?.educationCollection.append(education!)
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
        
        let index = profile.individualProfile?.educationCollection.index(where: { (education) -> Bool in
            education.degreeEarned == self.education?.degreeEarned && education.schoolName == self.education?.schoolName && education.schoolLocation == self.education?.schoolLocation
        })
        
        if let educationIndex = index {
            profile.individualProfile?.educationCollection.remove(at: educationIndex)
            profile.save()
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
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
