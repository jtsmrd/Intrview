//
//  LoginViewController.swift
//  SnapInterview
//
//  Created by JT Smrdel on 2/1/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables and Constants
    
    @IBOutlet weak var emailTextField: UITextField!      
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    var currentFirstResponder: UIView!
    var deleted: Bool = false
    var count = 0
    var navToolBar: UIToolbar!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var profileTBC: ProfileTBC!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navToolBar = createKeyboardToolBar()
        
        versionLabel.text = "Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // Dismiss the keyboard when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    // MARK: - Actions
    
    @IBAction func privacyPolicyButtonAction(_ sender: AnyObject) {
        
        if let privacyPolicyURL = Global.configuration.privacyPolicyURL {
            UIApplication.shared.open(URL(string: privacyPolicyURL)!, options: [:], completionHandler: nil)
        }
        else {
            UIApplication.shared.open(URL(string: "http://www.intrview.ametapps.io")!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func loginAction() {
        
        view.endEditing(true)
        disableViews()
        login()
    }
    
    // Reset password
    @IBAction func forgotPasswordButtonAction(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "", message: "Forgot Password?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let forgotPasswordAction = UIAlertAction(title: "Reset Password", style: .default) { (action) in
            
            if self.emailTextField.text == "" {
                self.alert("Email missing", message: "Enter the email registered with your account.")
            }
            else {
                FIRAuth.auth()?.sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                    if let error = error {
                        DispatchQueue.main.async(execute: {
                            self.alert("There was an issue.", message: error.localizedDescription)
                        })
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            self.alert("Reset password email sent", message: "An email has been sent with further instructions to reset your password.")
                        })
                    }
                })
            }
        }
        alertController.addAction(forgotPasswordAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Private Methods
    
    fileprivate func disableViews() {
        
        loginButton.isEnabled = false
        signupButton.isEnabled = false
        forgotPasswordButton.isEnabled = false
    }
    
    fileprivate func enableViews() {
        
        loginButton.isEnabled = true
        signupButton.isEnabled = true
        forgotPasswordButton.isEnabled = true
    }
    
    // Set the login status and show the profile
    private func login() {
        
        FIRAuth(app: FIRApp.defaultApp()!)?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if let error = error {
                self.enableViews()
                self.alert("Login Failed", message: error.localizedDescription)
            }
            else if let user = user {
                
                if user.email == self.profile.email {
                    self.showProfile()
                }
                else {
                    self.fetchProfile(firebaseUID: user.uid)
                }
            }
        })
    }
    
    func showProfile() {
        
        DispatchQueue.main.async {
            self.enableViews()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func fetchProfile(firebaseUID: String) {
        
        profile.fetchProfile(with: firebaseUID) { (profileType) in
            if let profileType = profileType {
                self.profile.profileType = profileType
                self.showProfile()
            }
            else {
                print("Error fetching profile: ProfileType is nil")
            }
        }
    }
    
    // Show alert controller
    fileprivate func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title,
            message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentFirstResponder = textField
        textField.inputAccessoryView = navToolBar
    }
    
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
