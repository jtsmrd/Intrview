//
//  SignUpVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 6/17/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UITextFieldDelegate {

    // MARK: - Variables and Constants
    
    @IBOutlet weak var profileTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var count = 0
    var currentFirstResponder: UIView!
    var navToolBar: UIToolbar!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var email: String {
        
        get {
            return (emailTextField.text?.lowercased())!
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navToolBar = createKeyboardToolBar()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Sign Up"
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = Global.greenColor
        
        profile.profileType = ProfileType.Business
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @objc func backButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        
        disableViews()
        createProfile()
    }
    
    @IBAction func profileTypeSegmentedControlAction(_ sender: UISegmentedControl) {
        
        if profileTypeSegmentedControl.selectedSegmentIndex == 0 {
            profile.profileType = ProfileType.Business
        }
        else {
            profile.profileType = ProfileType.Individual
        }
    }
    
    // MARK: Private Methods
    
    fileprivate func disableViews() {
        
        DispatchQueue.main.async {
            self.signUpButton.isEnabled = false
            self.signUpButton.alpha = 0.5
        }
    }
    
    fileprivate func enableViews() {
        
        DispatchQueue.main.async {
            self.signUpButton.isEnabled = true
            self.signUpButton.alpha = 1.0
        }
    }
    
    // Validate and create an IndividualProfile
    fileprivate func createProfile() {
        
        if let errorMessage = validateTextFields() {
            enableViews()
            showErrorAlert(errorMessage)
        }
        else {
            createFirebaseUserAccount()
        }
    }
    
    // Make sure textfields contain text
    fileprivate func validateTextFields() -> String? {
        
        var errorMessage: String?
        
        if emailTextField.text == "" {
            errorMessage = "The Email field is required."
        }
        else if passwordTextField.text == "" {
            errorMessage = "The Password field is required."
        }
        
        return errorMessage
    }
    
    // Show alert controller with error message
    fileprivate func showErrorAlert(_ errorMessage: String) {
        
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Create Firebase account with email/password for authentication
    fileprivate func createFirebaseUserAccount() {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: passwordTextField.text!, completion: { (user, error) in
            if let error = error {
                self.enableViews()
                self.showErrorAlert(error.localizedDescription)
                Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
            else if let user = user {
                
                self.profile.email = self.email
                self.profile.firebaseUID = user.uid
                self.profile.loadProfile()
                self.enableViews()
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
    }
    
    // MARK: Keyboard Toolbar
    
    @objc func doneAction() {
        currentFirstResponder.resignFirstResponder()
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
