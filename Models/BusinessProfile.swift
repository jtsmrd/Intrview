//
//  BusinessProfileNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/4/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class BusinessProfile {
    
    // MARK: Constants
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let imageStore = ImageStore()
    let userDefaults = UserDefaults.standard
    
    // MARK: Variables
    
    var about: String?
    var cKRecordName: String?
    var firebaseUID: String?
    var email: String?
    var contactEmail: String?
    var location: String?
    var name: String?
    var profileImageKey: String?
    var profileImageCKRecordName: String?
    var website: String?
    var profileImage: UIImage?
    var interviewCollection = InterviewCollection()
    var interviewTemplateCollection = InterviewTemplateCollection()
    var previousSearches = [IndividualProfile]()
    var spotlightCollection = SpotlightCollection()
    
    var spotlightCKRecordNames: [String]? {
        get {
            return userDefaults.array(forKey: "SpotlightCKRecordNames") as! [String]?
        }
        set(array) {
            userDefaults.set(array, forKey: "SpotlightCKRecordNames")
            userDefaults.synchronize()
        }
    }
    
    // MARK: Initializers
    
    /// Default initializer
    init() {
        
    }
    
    /// Initialize an BusinessProfile object using a CKRecord
    ///
    /// - Parameter cloudKitRecord: CloudKit record of the BusinessProfile
    init(with cloudKitRecord: CKRecord) {
        
        populate(with: cloudKitRecord)
    }
    
    /// Initialize an BusinessProfile object using it's associated CKRecordName
    ///
    /// - Parameter cKRecordName: The CKRecordName of the BusinessProfile
    init(with cKRecordName: String) {
        
        fetch(with: cKRecordName) { (record, error) in
            if let error = error {
                print(error)
            }
            else if let record = record {
                self.populate(with: record)
            }
        }
    }
    
    // MARK: Private Functions
    
    private func populate(with cKRecord: CKRecord) {
        
        self.about = cKRecord.value(forKey: "about") as? String
        self.cKRecordName = cKRecord.recordID.recordName
        self.firebaseUID = cKRecord.value(forKey: "firebaseUID") as? String
        self.email = cKRecord.value(forKey: "email") as? String
        self.contactEmail = cKRecord.value(forKey: "contactEmail") as? String
        self.location = cKRecord.value(forKey: "location") as? String
        self.name = cKRecord.value(forKey: "name") as? String
        self.profileImageCKRecordName = cKRecord.value(forKey: "profileImageCKRecordName") as? String
        self.website = cKRecord.value(forKey: "website") as? String
        
        if let searches = cKRecord.object(forKey: "previousSearches") as? [CKReference] {
            self.fetchPreviousSearches(from: searches)
        }
        
        self.profileImageKey = self.profileImageCKRecordName
        
        if let imageKey = self.profileImageKey {
            if let image = imageStore.imageForKey(imageKey) {
                self.profileImage = image
            }
        }
    }
    
    private func fetchPreviousSearches(from references: [CKReference]) {
        
        for reference in references {
            publicDatabase.fetch(withRecordID: reference.recordID, completionHandler: { (record, error) in
                if let error = error {
                    print(error)
                }
                else if let record = record {
                    self.previousSearches.append(IndividualProfile(with: record))
                }
            })
        }
    }
    
    private func fetch(with cKRecordName: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let businessProfileCKRecordID = CKRecordID(recordName: cKRecordName)
        publicDatabase.fetch(withRecordID: businessProfileCKRecordID) { (record, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let record = record {
                completion(record, nil)
            }
        }
    }
    
    private func create(completion: @escaping (() -> Void)) {
        
        let newRecord = CKRecord(recordType: "BusinessProfile")
        let populatedRecord = setCKRecordValues(for: newRecord)
        publicDatabase.save(populatedRecord) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                self.cKRecordName = record.recordID.recordName
                completion()
            }
        }
    }
    
    private func update(cKRecordName: String, completion: @escaping (() -> Void)) {
        
        fetch(with: cKRecordName) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                
                let updatedRecord = self.setCKRecordValues(for: record)
                
                self.publicDatabase.save(updatedRecord, completionHandler: { (record, error) in
                    if let error = error {
                        print(error)
                    }
                    completion()
                })
            }
        }
    }
    
    private func setCKRecordValues(for record: CKRecord) -> CKRecord {
        
        record.setValue(self.about, forKey: "about")
        record.setValue(self.firebaseUID, forKey: "firebaseUID")
        record.setValue(self.email, forKey: "email")
        record.setValue(self.contactEmail, forKey: "contactEmail")
        record.setValue(self.location, forKey: "location")
        record.setValue(self.name, forKey: "name")
        record.setValue(self.profileImageCKRecordName, forKey: "profileImageCKRecordName")
        record.setValue(self.website, forKey: "website")
        
        let searchName = name?.lowercased().replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        record.setValue(searchName, forKey: "searchName")
        
        return record
    }
    
    private func deleteImage(imageCKRecordName: String, completion: @escaping (() -> Void)) {
        
        let imageCKRecordID = CKRecordID(recordName: imageCKRecordName)
        publicDatabase.delete(withRecordID: imageCKRecordID) { (recordID, error) in
            if let error = error {
                print(error)
                completion()
            }
            else {
                self.imageStore.deleteImageForKey(self.profileImageKey!)
                completion()
            }
        }
    }
    
    private func saveImageToCloud(tempImageKey: String) {
        
        let imageRecord = CKRecord(recordType: "Image")
        let imageAsset = CKAsset(fileURL: imageStore.imageURLForKey(tempImageKey))
        imageRecord.setObject(imageAsset, forKey: "image")
        
        publicDatabase.save(imageRecord) { (record, error) in
            if let error = error {
                print(error)
            }
            else if let record = record {
                self.imageStore.deleteImageForKey(tempImageKey)
                self.profileImageCKRecordName = record.recordID.recordName
                self.profileImageKey = record.recordID.recordName
                self.imageStore.setImage(self.profileImage!, forKey: self.profileImageKey!)
            }
        }
    }
    
    private func fetchInterviewTemplates() {
        interviewTemplateCollection.fetchAllTemplates(with: cKRecordName!) { 
            
        }
    }
    
    private func fetchInterviews() {
        interviewCollection.fetchAllInterviews(with: cKRecordName!, profileType: .Business) { 
            
        }
    }
    
    private func fetchSpotlights() {
        spotlightCollection.fetchAllSpotlights(with: cKRecordName!, profileType: .Business) { 
            
        }
    }
    
    // MARK: Public Functions
    
    func addSpotlightCKRecordName(spotlightCKRecordName: String) {
        
        var existingSpotlightCKRecordNames = [String]()
        
        if let existingInterviews = self.spotlightCKRecordNames {
            existingSpotlightCKRecordNames = existingInterviews
        }
        
        if !existingSpotlightCKRecordNames.contains(spotlightCKRecordName) {
            existingSpotlightCKRecordNames.append(spotlightCKRecordName)
            self.spotlightCKRecordNames = existingSpotlightCKRecordNames
        }
    }
    
    func removeSpotlightCKRecordName(spotlightCKRecordName: String) {
        
        let index = self.spotlightCKRecordNames?.index(where: { (recordName) -> Bool in
            recordName == spotlightCKRecordName
        })
        
        if let recordIndex = index {
            var newSpotlightCKRecordnames = self.spotlightCKRecordNames
            newSpotlightCKRecordnames?.remove(at: recordIndex)
            self.spotlightCKRecordNames = newSpotlightCKRecordnames
        }
    }
    
    func fetchImage(imageCKRecordName: String, completion: @escaping (() -> Void)) {
        
        let imageCKRecordID = CKRecordID(recordName: imageCKRecordName)
        publicDatabase.fetch(withRecordID: imageCKRecordID) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                if let imageAsset = record.object(forKey: "image") as? CKAsset {
                    let imageData = try? Data(contentsOf: URL(fileURLWithPath: imageAsset.fileURL.path))
                    self.profileImage = UIImage(data: imageData!)
                }
                completion()
            }
        }
    }
    
    func saveImage(tempImageKey: String) {
        
        if self.profileImageCKRecordName != nil {
            deleteImage(imageCKRecordName: self.profileImageCKRecordName!, completion: {
                self.saveImageToCloud(tempImageKey: tempImageKey)
            })
        }
        else {
            saveImageToCloud(tempImageKey: tempImageKey)
        }
    }
    
    func forceFetch(with cKRecordName: String, completion: @escaping (() -> Void)) {
        
        fetch(with: cKRecordName) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                self.populate(with: record)
                completion()
                self.fetchInterviewTemplates()
                self.fetchSpotlights()
            }
        }
    }
    
    func fetchWithFirebaseUID(firebaseUID: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let query = CKQuery(recordType: "BusinessProfile", predicate: NSPredicate(format: "firebaseUID = %@", firebaseUID))
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let records = records {
                if !records.isEmpty {
                    completion(records.first, nil)
                }
                else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func delete() {
        
        if let profileImageCKRecordName = self.profileImageCKRecordName {
            
            let profileImageCKRecordID = CKRecordID(recordName: profileImageCKRecordName)
            publicDatabase.delete(withRecordID: profileImageCKRecordID, completionHandler: { (recordID, error) in
                if let error = error {
                    print(error)
                }
            })
        }
        
        let profileCKRecordID = CKRecordID(recordName: self.cKRecordName!)
        publicDatabase.delete(withRecordID: profileCKRecordID) { (recordID, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func save(completion: @escaping (() -> Void)) {
        
        if let recordName = self.cKRecordName {
            update(cKRecordName: recordName, completion: {
                completion()
            })
        }
        else {
            create(completion: {
                self.subscribeToNewSpotlights()
                completion()
            })
        }
    }
    
    func subscribeToInterviewRecord(interviewCKRecordName: String, individualName: String) {
        
        let interviewCKRecordID = CKRecordID(recordName: interviewCKRecordName)
        
        //        var interviewSubscriptions = UserDefaults.standard.dictionary(forKey: "InterviewSubscriptions")
        //        interviewSubscriptions!["\(interviewRecord.recordID.recordName)"] = [String]()
        
        var predicate = NSPredicate(format: "%K = %@ AND interviewStatus = %@", "recordID", interviewCKRecordID, "Complete")
        var subscription = CKQuerySubscription(recordType: "Interview", predicate: predicate, options: .firesOnRecordUpdate)
        var notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "\(individualName) completed your Interview."
        notificationInfo.shouldBadge = true
        notificationInfo.category = "BusinessProfileNotification"
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription, completionHandler: { (subscription, error) -> Void in
            if let error = error {
                Logger.logError("Sub1 Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
            else if let subscription = subscription {
                print("Successfully added BusinessProfile subscription: \(subscription)")
                
                //                var subscriptionIDs = interviewSubscriptions!["\(interviewRecord.recordID.recordName)"] as? [String]
                //                subscriptionIDs?.append(subscription.subscriptionID)
                //                interviewSubscriptions!["\(interviewRecord.recordID.recordName)"] = subscriptionIDs
                //                UserDefaults.standard.set(interviewSubscriptions, forKey: "InterviewSubscriptions")
                //                UserDefaults.standard.synchronize()
            }
        })
        
        predicate = NSPredicate(format: "%K = %@ AND interviewStatus = %@", "recordID", interviewCKRecordID, "Declined")
        subscription = CKQuerySubscription(recordType: "Interview", predicate: predicate, options: .firesOnRecordUpdate)
        
        notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "\(individualName) declined your Interview."
        notificationInfo.shouldBadge = true
        notificationInfo.category = "BusinessProfileNotification"
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription, completionHandler: { (subscription, error) -> Void in
            if let error = error {
                Logger.logError("Sub2 Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
            else if let subscription = subscription {
                print("Successfully added BusinessProfile subscription: \(subscription)")
                //                var subscriptionIDs = interviewSubscriptions!["\(interviewRecord.recordID.recordName)"] as? [String]
                //                subscriptionIDs?.append(subscription.subscriptionID)
                //                interviewSubscriptions!["\(interviewRecord.recordID.recordName)"] = subscriptionIDs
                //                UserDefaults.standard.set(interviewSubscriptions, forKey: "InterviewSubscriptions")
                //                UserDefaults.standard.synchronize()
            }
        }) 
    }
    
    func subscribeToNewSpotlights() {
        
        let predicate = NSPredicate(format: "businessProfileCKRecordName = %@", self.cKRecordName!)
        let subscription = CKQuerySubscription(recordType: "Spotlight", predicate: predicate, options: .firesOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "You have a new Spotlight!"
        notificationInfo.shouldBadge = true
        notificationInfo.category = "BusinessProfileSpotlightNotification"
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription, completionHandler: { (subscription, error) -> Void in
            if let error = error {
                Logger.logError("Sub3 Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
            else if let subscription = subscription {
                print("Successfully added BusinessProfile subscription: \(subscription)")
            }
        })
    }
}
