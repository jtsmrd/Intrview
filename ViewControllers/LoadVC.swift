//
//  LoadVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/27/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import Firebase

class LoadVC: UIViewController {

    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var profileTBC: ProfileTBC!
    var delete: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if delete {
            deleteProfile()
        }
        else {
            let currentUser = FIRAuth.auth()?.currentUser
            
            if currentUser != nil && currentUser?.email == profile.email {
                showProfile()
            }
            else {
                performSegue(withIdentifier: "showLogin", sender: nil)
            }
        }
    }

    private func deleteProfile() {
        
        delete = false
        profile.delete()
        performSegue(withIdentifier: "showLogin", sender: nil)
    }
    
    func showProfile() {
        
        profileTBC = ProfileTBC()
        
        if profile.exists {
            if let recordName = profile.cKRecordName {
                switch profile.profileType! {
                    
                case ProfileType.Individual:
                    profileTBC.profileTVC.profileType = ProfileType.Individual
                    
                    profile.individualProfile?.forceFetch(with: recordName, completion: {
                        self.profileTBC.profileTVC.individualProfile = self.profile.individualProfile!
                        
                        DispatchQueue.main.async {
                            self.present(self.profileTBC, animated: false, completion: nil)
                        }
                    })
                    
                case ProfileType.Business:
                    profileTBC.profileTVC.profileType = ProfileType.Business
                    
                    profile.businessProfile?.forceFetch(with: recordName, completion: {
                        self.profileTBC.profileTVC.businessProfile = self.profile.businessProfile!
                        
                        DispatchQueue.main.async {
                            self.present(self.profileTBC, animated: false, completion: nil)
                        }
                    })
                }
            }
        }
        else {
            switch profile.profileType! {
                
            case ProfileType.Individual:
                profileTBC.profileTVC.profileType = ProfileType.Individual
                profileTBC.profileTVC.individualProfile = profile.individualProfile
                present(profileTBC, animated: false, completion: nil)
                
            case ProfileType.Business:
                profileTBC.profileTVC.profileType = ProfileType.Business
                profileTBC.profileTVC.businessProfile = profile.businessProfile
                present(profileTBC, animated: false, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLogin" {
            let destinationVC = segue.destination as! UINavigationController
            present(destinationVC, animated: true, completion: nil)
        }
    }
}
