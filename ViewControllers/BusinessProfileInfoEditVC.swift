//
//  BusinessProfileInfoEditVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/16/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class BusinessProfileInfoEditVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var addReplaceImageButton: UIButton!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imageStore = ImageStore()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        navToolBar = createKeyboardToolBar()
        
        configureView()
    }

    @objc func saveButtonAction() {
        
        profile.businessProfile?.name = companyNameTextField.text
        profile.businessProfile?.location = locationTextField.text
        profile.businessProfile?.contactEmail = contactEmailTextField.text
        profile.businessProfile?.website = websiteTextField.text
        
        profile.save()
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonAction() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addReplaceImageButtonAction(_ sender: Any) {
        addProfileImage()
    }

    private func configureView() {
        
        self.companyNameTextField.text = profile.businessProfile?.name
        self.locationTextField.text = profile.businessProfile?.location
        self.contactEmailTextField.text = profile.businessProfile?.contactEmail
        self.websiteTextField.text = profile.businessProfile?.website
        
        if let image = profile.businessProfile?.profileImage {
            profileImageView.image = image
            addReplaceImageButton.setTitle("Replace Image", for: .normal)
        }
        else {
            profileImageView.image = UIImage(named: "default_profile_image")
            addReplaceImageButton.setTitle("Add Image", for: .normal)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let currentTextFieldOrigin = currentFirstResponder.frame.origin
        let currentTextFieldHeight = currentFirstResponder.frame.size.height
        var visibleRect = view.frame
        visibleRect.size.height -= keyboardHeight
        let scrollPoint = CGPoint(x: 0.0, y: currentTextFieldOrigin.y - visibleRect.size.height + (currentTextFieldHeight * 3))
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: - ImageView Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageKey = UUID().uuidString
        profileImageView.image = image
        imageStore.setImage(image, forKey: imageKey)
        profile.businessProfile?.profileImage = image
        profile.businessProfile?.saveImage(tempImageKey: imageKey)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addProfileImage() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
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
