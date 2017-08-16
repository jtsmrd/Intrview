//
//  SkillsEditVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class SkillsEditVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var skillsTextView: UITextView!
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var currentFirstResponder: UIView!
    var navToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))
        saveBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        if let skills = profile.individualProfile?.skills {
            skillsTextView.text = skills
        }
        else {
            skillsTextView.text = "Skills"
        }
        
        navToolBar = createKeyboardToolBar()
    }

    @objc func saveButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        profile.individualProfile?.skills = skillsTextView.text
        profile.save()
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonAction() {
        
        if currentFirstResponder != nil {
            currentFirstResponder.resignFirstResponder()
        }
        
        let _ = navigationController?.popViewController(animated: true)
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
    
    private func createKeyboardToolBar() -> UIToolbar {
        
        let keyboardToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        keyboardToolBar.barStyle = .default
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        done.width = 50
        done.tintColor = Global.greenColor
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        keyboardToolBar.items = [flexSpace, done]
        keyboardToolBar.sizeToFit()
        
        return keyboardToolBar
    }
}
