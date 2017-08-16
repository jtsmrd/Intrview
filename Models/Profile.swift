//
//  Profile.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/4/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

enum ProfileType: String {
    
    case Individual = "Individual"
    case Business = "Business"
}

class Profile {
    
    let configuration = Configuration()
    let userDefaults = UserDefaults.standard
    let imageStore = ImageStore()
    
    var businessProfile: BusinessProfile?
    var individualProfile: IndividualProfile?
    var previousSearchCollection = PreviousSearchCollection()
    
    var cKRecordName: String? {
        get {
            return userDefaults.string(forKey: "CKRecordName")
        }
        set(cKRecordName) {
            userDefaults.set(cKRecordName, forKey: "CKRecordName")
            userDefaults.synchronize()
        }
    }
    
    var newIntervivewCount: Int? {
        get {
            return userDefaults.integer(forKey: "NewInterviewCount")
        }
        set(count) {
            userDefaults.set(count, forKey: "NewInterviewCount")
            userDefaults.synchronize()
        }
    }
    
    var spotlightViewCount: Int? {
        get {
            return userDefaults.integer(forKey: "SpotlightViewCount")
        }
        set(count) {
            userDefaults.set(count, forKey: "SpotlightViewCount")
            userDefaults.synchronize()
        }
    }
    
    var firebaseUID: String? {
        get {
            return userDefaults.string(forKey: "FirebaseUID")
        }
        set(firebaseUID) {
            userDefaults.set(firebaseUID, forKey: "FirebaseUID")
            userDefaults.synchronize()
        }
    }
    
    var profileType: ProfileType? {
        get {
            let rawEnum = userDefaults.value(forKey: "ProfileType") as? String
            if let enumRawValue = rawEnum {
                return ProfileType(rawValue: enumRawValue)
            }
            else {
                return nil
            }
        }
        set(profileType) {
            userDefaults.set(profileType?.rawValue, forKey: "ProfileType")
            userDefaults.synchronize()
        }
    }
    
    var profileImageKey: String? {
        get {
            return userDefaults.string(forKey: "ProfileImageKey")
        }
        set(profileImageKey) {
            userDefaults.set(profileImageKey, forKey: "ProfileImageKey")
            userDefaults.synchronize()
        }
    }
    
    var email: String? {
        get {
            return userDefaults.string(forKey: "Email")
        }
        set(email) {
            userDefaults.set(email, forKey: "Email")
            userDefaults.synchronize()
        }
    }
    
    var exists: Bool {
        get {
            return cKRecordName == nil ? false : true
        }
    }
    
    var cKSubscriptions: [String : AnyObject]? {
        get {
            return userDefaults.dictionary(forKey: "CKSubscriptions") as [String : AnyObject]?
        }
        set(cKSubscriptions) {
            userDefaults.set(cKSubscriptions, forKey: "CKSubscriptions")
            userDefaults.synchronize()
        }
    }
    
    // MIGHT NOT NEED THIS
    var isLoggedIn: Bool {
        get {
            return userDefaults.bool(forKey: "IsLoggedIn")
        }
        set(isLoggedIn) {
            userDefaults.set(isLoggedIn, forKey: "IsLoggedIn")
            userDefaults.synchronize()
        }
    }
    
    // MIGHT NOT NEED THIS
    var isFirstLogin: Bool {
        get {
            return userDefaults.bool(forKey: "IsFirstLogin")
        }
        set(isFirstLogin) {
            userDefaults.set(isFirstLogin, forKey: "IsFirstLogin")
            userDefaults.synchronize()
        }
    }
    
    init() {
        
        if let type = profileType {
            
            switch type {
                
            case ProfileType.Business:
                businessProfile = BusinessProfile()
                
            case ProfileType.Individual:
                individualProfile = IndividualProfile()
            }
        }
    }
    
    func loadProfile() {
        
        if let type = profileType {
            
            switch type {
                
            case ProfileType.Business:
                
                if exists {
                    businessProfile = BusinessProfile(with: cKRecordName!)
                }
                else {
                    businessProfile = BusinessProfile()
                }
                
            case ProfileType.Individual:
                
                if exists {
                    individualProfile = IndividualProfile(with: cKRecordName!)
                }
                else {
                    individualProfile = IndividualProfile()
                }
            }
        }
    }
    
    func save() {
        
        switch profileType! {
            
        case ProfileType.Business:
            
            self.businessProfile?.firebaseUID = self.firebaseUID
            self.businessProfile?.email = self.email
            self.businessProfile?.save(completion: {
                self.cKRecordName = self.businessProfile?.cKRecordName
            })
            
        case ProfileType.Individual:
            
            self.individualProfile?.firebaseUID = self.firebaseUID
            self.individualProfile?.email = self.email
            self.individualProfile?.save(completion: { 
                self.cKRecordName = self.individualProfile?.cKRecordName
            })
        }
    }
    
    func fetchProfile(with firebaseUID: String, completion: @escaping ((ProfileType?) -> Void)) {
        
        // Check Individual Profile first
        individualProfile = IndividualProfile()
        individualProfile?.fetchWithFirebaseUID(firebaseUID: firebaseUID, completion: { (individualProfileRecord, error) in
            if let error = error {
                print(error)
                completion(nil)
            }
            else if let individualProfileRecord = individualProfileRecord {
                self.individualProfile = IndividualProfile(with: individualProfileRecord)
                self.configureWithIndividualProfile(individualProfile: self.individualProfile!)
                completion(ProfileType.Individual)
            }
            else {
                self.businessProfile = BusinessProfile()
                self.businessProfile?.fetchWithFirebaseUID(firebaseUID: firebaseUID, completion: { (businessProfileRecord, error) in
                    if let error = error {
                        print(error)
                        completion(nil)
                    }
                    else if let businessProfileRecord = businessProfileRecord {
                        self.businessProfile = BusinessProfile(with: businessProfileRecord)
                        self.configureWithBusinessProfile(businessProfile: self.businessProfile!)
                        completion(ProfileType.Business)
                    }
                    else {
                        print("Error fetching profile.")
                        completion(nil)
                    }
                })
            }
        })
    }
    
    func configureWithIndividualProfile(individualProfile: IndividualProfile) {
        
        resetUserDefaults()
        
        self.cKRecordName = individualProfile.cKRecordName
        self.firebaseUID = individualProfile.firebaseUID
        self.profileType = ProfileType.Individual
        self.email = individualProfile.email
        
        // Fetch profile image
        if let imageCKRecordName = self.individualProfile?.profileImageCKRecordName {
            self.individualProfile?.fetchProfileImage(imageCKRecordName: imageCKRecordName, completion: {
                self.individualProfile?.profileImageKey = self.individualProfile?.profileImageCKRecordName
                self.profileImageKey = self.individualProfile?.profileImageKey
                self.imageStore.setImage((self.individualProfile?.profileImage)!, forKey: self.profileImageKey!)
            })
        }
        
        // Create subscriptions
        self.individualProfile?.createNewInterviewSubscription()
    }
    
    func configureWithBusinessProfile(businessProfile: BusinessProfile) {
        
        resetUserDefaults()
        
        self.cKRecordName = businessProfile.cKRecordName
        self.firebaseUID = businessProfile.firebaseUID
        self.profileType = ProfileType.Business
        self.email = businessProfile.email
        
        // Fetch profile image
        self.businessProfile?.fetchImage(imageCKRecordName: (self.businessProfile?.profileImageCKRecordName)!, completion: {
            self.businessProfile?.profileImageKey = self.businessProfile?.profileImageCKRecordName
            self.profileImageKey = self.businessProfile?.profileImageKey
            self.imageStore.setImage((self.businessProfile?.profileImage)!, forKey: self.profileImageKey!)
        })
        
        // Create subscriptions
    }
    
    func delete() {
        
        deleteSpotlights()
        deleteInterviews()
        deleteInterviewTemplates()
        deleteProfile()
        resetUserDefaults()
    }
    
    private func deleteProfile() {
        
        switch profileType! {
            
        case ProfileType.Business:
            self.businessProfile?.delete()
            
        case ProfileType.Individual:
            self.individualProfile?.delete()
        }
    }
    
    private func deleteInterviewTemplates() {
        
        switch profileType! {
        case ProfileType.Business:
            
            if let interviewTemplates = self.businessProfile?.interviewTemplateCollection.interviewTemplates {
                for interviewTemplate in interviewTemplates {
                    interviewTemplate.delete()
                }
            }
            
        case ProfileType.Individual:
            return
        }
    }
    
    private func deleteInterviews() {
        
        switch profileType! {
            
        case ProfileType.Business:
            
            if let interviews = self.businessProfile?.interviewCollection.interviews {
                for interview in interviews {
                    interview.delete()
                }
            }
            
        case ProfileType.Individual:
            
            if let interviews = self.individualProfile?.interviewCollection.interviews {
                for interview in interviews {
                    interview.delete()
                }
            }
        }
    }
    
    private func deleteSpotlights() {
        
        switch profileType! {
            
        case ProfileType.Business:
            
            if let spotlights = self.businessProfile?.spotlightCollection.spotlights {
                for spotlight in spotlights {
                    spotlight.delete()
                }
            }
            
        case ProfileType.Individual:
            
            if let spotlights = self.individualProfile?.spotlightCollection.spotlights {
                for spotlight in spotlights {
                    spotlight.delete()
                }
            }
        }
    }
    
    func resetUserDefaults() {
        
        cKRecordName = nil
        firebaseUID = nil
        profileType = nil
        profileImageKey = nil
        email = nil
        cKSubscriptions = nil
    }
}
