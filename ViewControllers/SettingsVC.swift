//
//  SettingsVC2.swift
//  SnapInterview
//
//  Created by JT Smrdel on 8/24/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import CloudKit
import MessageUI

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate {

    // MARK: - Variables, Outlets, and Constants
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let imageStore = (UIApplication.shared.delegate as! AppDelegate).imageStore
    let videoStore = (UIApplication.shared.delegate as! AppDelegate).videoStore
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "Settings"
        
        let backButton = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        versionLabel.text = "Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
    }
    
    // MARK: - Actions
    
    @objc func backButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        do {
            try FIRAuth.auth()?.signOut()
        }
        catch let error as NSError {
            Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
        }
        
        profile.resetUserDefaults()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordButtonAction(_ sender: AnyObject) {
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: self.profile.email!, completion: { (error) in
            if let error = error {
                Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
            else {
                DispatchQueue.main.async {
                    self.alert("Reset password", message: "An email to reset your password has been sent.")
                }
            }
        })
    }
    
    @IBAction func contactSupportButtonAction(_ sender: AnyObject) {
        
        let mailComposeViewController = self.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            self.alert("Could not send email.", message: "Your device could not send the email.")
        }
    }
    
    @IBAction func deleteAccountButtonAction(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Delete Account", message: "Enter your password to delete your account.", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            let email = self.profile.email!
            let password = alertController.textFields![0].text!
            
            FIRAuth(app: FIRApp.defaultApp()!)?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    self.alert("Error", message: error.localizedDescription)
                }
                else if let user = user {
                    user.delete(completion: { (error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            let loadVC = self.parent?.parent?.presentingViewController?.childViewControllers.first as! LoadVC
                            loadVC.delete = true
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            })
        }
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    fileprivate func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        if Global.configuration.supportEmail != "" {
            mailComposerVC.setToRecipients([(Global.configuration).supportEmail!])
        }
        else {
            mailComposerVC.setToRecipients(["intrviewapp@gmail.com"])
        }
        mailComposerVC.setSubject("Customer Support")
        return mailComposerVC
    }
    
    fileprivate func alert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title,
                                          message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Delegate Methods
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: false, completion: nil)
    }
}
