//
//  IndividualProfileNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/4/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class IndividualProfile {
    
    // MARK: Constants
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let imageStore = ImageStore()
    let userDefaults = UserDefaults.standard
    
    // MARK: Variables
    
    var email: String?
    var contactEmail: String?
    var contactPhone: String?
    var cKRecordName: String?
    var firebaseUID: String?
    var location: String?
    var name: String?
    var personalSummary: String?
    var profession: String?
    var profileImageKey: String?
    var profileImageCKRecordName: String?
    var profileImage: UIImage?
    var skills: String?
    var resumeName: String?
    var resumeImageCKRecordName: String?
    var resumeImageKey: String?
    var resumeImage: UIImage?
    var educationCollection = [Education]()
    var workExperienceCollection = [WorkExperience]()
    var interviewCollection = InterviewCollection()
    var spotlightCollection = SpotlightCollection()
    
//    var interviewCKRecordNames: [String]? {
//        get {
//            return userDefaults.array(forKey: "InterviewCKRecordNames") as! [String]?
//        }
//        set(array) {
//            userDefaults.set(array, forKey: "InterviewCKRecordNames")
//            userDefaults.synchronize()
//        }
//    }
    
    // MARK: Initializers
    
    /// Default initializer
    init() {
        
    }
    
    /// Initialize an IndividualProfile object using a CKRecord
    ///
    /// - Parameter cloudKitRecord: CloudKit record of the IndividualProfile
    init(with cloudKitRecord: CKRecord) {
        
        populate(with: cloudKitRecord)
    }
    
    
    /// Initialize an IndividualProfile object using it's associated CKRecordName
    ///
    /// - Parameter cKRecordName: The CKRecordName of the IndividualProfile
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
        
        self.email = cKRecord.value(forKey: "email") as? String
        self.contactEmail = cKRecord.value(forKey: "contactEmail") as? String
        self.contactPhone = cKRecord.value(forKey: "contactPhone") as? String
        self.cKRecordName = cKRecord.recordID.recordName
        self.firebaseUID = cKRecord.value(forKey: "firebaseUID") as? String
        self.location = cKRecord.value(forKey: "location") as? String
        self.name = cKRecord.value(forKey: "name") as? String
        self.personalSummary = cKRecord.value(forKey: "personalSummary") as? String
        self.profession = cKRecord.value(forKey: "profession") as? String
        self.profileImageCKRecordName = cKRecord.value(forKey: "profileImageCKRecordName") as? String
        self.skills = cKRecord.value(forKey: "skills") as? String
        self.resumeName = cKRecord.value(forKey: "resumeName") as? String
        self.resumeImageCKRecordName = cKRecord.value(forKey: "resumeCKRecordName") as? String
        
        let workExperienceData = cKRecord.value(forKey: "workExperienceData") as? String
        if let data = workExperienceData {
            self.workExperienceCollection.removeAll()
            self.createWorkExperienceObjects(data)
        }
        
        let educationData = cKRecord.value(forKey: "educationData") as? String
        if let data = educationData {
            self.educationCollection.removeAll()
            self.createEducationObjects(data)
        }
        
        self.profileImageKey = self.profileImageCKRecordName
        
        if let imageKey = self.profileImageKey {
            if let image = imageStore.imageForKey(imageKey) {
                self.profileImage = image
            }
        }
        
        self.resumeImageKey = self.resumeImageCKRecordName
        
        if let resumeImageKey = self.resumeImageKey {
            
            if let image = imageStore.imageForKey(resumeImageKey) {
                self.resumeImage = image
            }
            else {
                fetchResumeImage(imageCKRecordName: resumeImageKey, completion: {
                    
                })
            }
        }
    }
    
    private func fetch(with cKRecordName: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let individualProfileCKRecordID = CKRecordID(recordName: cKRecordName)
        publicDatabase.fetch(withRecordID: individualProfileCKRecordID) { (record, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let record = record {
                completion(record, nil)
            }
        }
    }
    
    private func create(completion: @escaping (() -> Void)) {
        
        let newRecord = CKRecord(recordType: "IndividualProfile")
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
        
        record.setValue(self.email, forKey: "email")
        record.setValue(self.contactEmail, forKey: "contactEmail")
        record.setValue(self.contactPhone, forKey: "contactPhone")
        record.setValue(self.firebaseUID, forKey: "firebaseUID")
        record.setValue(self.location, forKey: "location")
        record.setValue(self.name, forKey: "name")
        record.setValue(self.personalSummary, forKey: "personalSummary")
        record.setValue(self.profession, forKey: "profession")
        record.setValue(self.profileImageCKRecordName, forKey: "profileImageCKRecordName")
        record.setValue(self.skills, forKey: "skills")
        record.setValue(self.resumeName, forKey: "resumeName")
        record.setValue(self.resumeImageCKRecordName, forKey: "resumeCKRecordName")
        
        if workExperienceCollection.count > 0 {
            let workExperienceString = createWorkExperienceData()
            record.setValue(workExperienceString, forKey: "workExperienceData")
        }
        
        if educationCollection.count > 0 {
            let educationString = createEducationData()
            record.setValue(educationString, forKey: "educationData")
        }
        
        let searchName = name?.lowercased().replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        record.setValue(searchName, forKey: "searchName")
        
        return record
    }
    
    private func createWorkExperienceData() -> String {
        
        var workExperienceDictionary = [String: [String: AnyObject]]()
        for i in 0..<workExperienceCollection.count{
            workExperienceDictionary["\(i)"] = [String: AnyObject]()
            workExperienceDictionary["\(i)"]!["EmployerName"] = workExperienceCollection[i].employerName as AnyObject?
            workExperienceDictionary["\(i)"]!["JobTitle"] = workExperienceCollection[i].jobTitle as AnyObject?
            
            if let startDate = workExperienceCollection[i].startDate {
                workExperienceDictionary["\(i)"]!["StartDate"] = Global.dateFormatter.string(from: startDate) as AnyObject?
            }
            else {
                workExperienceDictionary["\(i)"]!["StartDate"] = "" as AnyObject?
            }
            
            if let endDate = workExperienceCollection[i].endDate {
                workExperienceDictionary["\(i)"]!["EndDate"] = Global.dateFormatter.string(from: endDate) as AnyObject?
            }
            else {
                workExperienceDictionary["\(i)"]!["EndDate"] = "" as AnyObject?
            }
        }
        let dictionaryString = Global.convertDictionaryToString(workExperienceDictionary as [String : AnyObject])
        return dictionaryString
    }
    
    private func createWorkExperienceObjects(_ workExperienceData: String) {
        
        if !workExperienceData.isEmpty {
            let workExperienceDictionary = Global.convertStringToDictionary(workExperienceData)
            
            if let experienceCount = workExperienceDictionary?.keys.count {
                
                for i in 0..<experienceCount {
                    
                    let workExperience = WorkExperience()
                    workExperience.employerName = workExperienceDictionary!["\(i)"]!["EmployerName"] as? String
                    workExperience.jobTitle = workExperienceDictionary!["\(i)"]!["JobTitle"] as? String
                    workExperience.startDate = Global.dateFormatter.date(from: (workExperienceDictionary!["\(i)"]!["StartDate"] as? String)!)
                    workExperience.endDate = Global.dateFormatter.date(from: (workExperienceDictionary!["\(i)"]!["EndDate"] as? String)!)
                    self.workExperienceCollection.append(workExperience)
                }
            }
        }
    }
    
    private func createEducationData() -> String {
        
        var educationDictionary = [String: [String: AnyObject]]()
        
        for i in 0..<educationCollection.count{
            educationDictionary["\(i)"] = [String: AnyObject]()
            educationDictionary["\(i)"]!["DegreeEarned"] = educationCollection[i].degreeEarned as AnyObject?
            educationDictionary["\(i)"]!["SchoolName"] = educationCollection[i].schoolName as AnyObject?
            educationDictionary["\(i)"]!["SchoolLocation"] = educationCollection[i].schoolLocation as AnyObject?
        }
        let dictionaryString = Global.convertDictionaryToString(educationDictionary as [String : AnyObject])
        return dictionaryString
    }
    
    private func createEducationObjects(_ educationData: String) {
        
        if !educationData.isEmpty {
            let educationDictionary = Global.convertStringToDictionary(educationData)
            
            if let educationCount = educationDictionary?.keys.count {
                
                for i in 0..<educationCount {
                    
                    let education = Education()
                    education.degreeEarned = educationDictionary!["\(i)"]!["DegreeEarned"] as? String
                    education.schoolName = educationDictionary!["\(i)"]!["SchoolName"] as? String
                    education.schoolLocation = educationDictionary!["\(i)"]!["SchoolLocation"] as? String
                    self.educationCollection.append(education)
                }
            }
        }
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
    
    private func saveProfileImageToCloud(tempImageKey: String) {
        
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
    
    private func saveResumeImageToCloud(tempImageKey: String, completion: @escaping (() -> Void)) {
        
        let imageRecord = CKRecord(recordType: "Image")
        let imageAsset = CKAsset(fileURL: imageStore.imageURLForKey(tempImageKey))
        imageRecord.setObject(imageAsset, forKey: "image")
        
        publicDatabase.save(imageRecord) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                self.imageStore.deleteImageForKey(tempImageKey)
                self.resumeImageCKRecordName = record.recordID.recordName
                self.resumeImageKey = record.recordID.recordName
                self.imageStore.setImage(self.resumeImage!, forKey: self.resumeImageKey!)
                completion()
            }
        }
    }
    
    func createNewInterviewSubscription() {
        
        let predicate = NSPredicate(format: "individualProfileCKRecordName = %@", self.cKRecordName!)
        let subscription = CKQuerySubscription(recordType: "Interview", predicate: predicate, options: .firesOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "You have a new Interview!"
        notificationInfo.shouldBadge = true
        notificationInfo.category = "IndividualProfileNotification"
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription, completionHandler: { (subscription, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let subscription = subscription {
                // Save in subscriptions
                print("Successful: \(subscription)")
            }
        })
    }
    
    func subscribeToSpotlightViews(spotlightCKRecordName: String, businessName: String) {
        
        let spotlightReference = CKReference(recordID: CKRecordID(recordName: spotlightCKRecordName), action: .none)
        let predicate = NSPredicate(format: "recordID = %@", spotlightReference.recordID)
        let subscription = CKQuerySubscription(recordType: "Spotlight", predicate: predicate, options: .firesOnRecordUpdate)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "\(businessName) viewed your Spotlight!"
        notificationInfo.shouldBadge = true
        notificationInfo.category = "IndividualProfileSpotlightViewed"
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription) { (subscription, error) in
            if let error = error {
                print(error)
            }
            else if let subscription = subscription {
                print("Successful: \(subscription)")
            }
        }
    }
    
    private func fetchSpotlights() {
        
        spotlightCollection.fetchAllSpotlights(with: cKRecordName!, profileType: ProfileType.Individual) { 
            
        }
    }
    
    private func fetchInterviews() {
        
        interviewCollection.fetchAllInterviews(with: cKRecordName!, profileType: ProfileType.Individual) { 
            
        }
    }
    
    // MARK: Public Functions
    
//    func addInterviewCKRecordName(interviewCKRecordName: String) {
//
//        var existingInterviewCKRecordNames = [String]()
//
//        if let existingInterviews = self.interviewCKRecordNames {
//            existingInterviewCKRecordNames = existingInterviews
//        }
//
//        if !existingInterviewCKRecordNames.contains(interviewCKRecordName) {
//            existingInterviewCKRecordNames.append(interviewCKRecordName)
//            self.interviewCKRecordNames = existingInterviewCKRecordNames
//        }
//    }
    
//    func removeInterviewCKRecordName(interviewCKRecordName: String) {
//
//        let index = self.interviewCKRecordNames?.index(where: { (recordName) -> Bool in
//            recordName == interviewCKRecordName
//        })
//
//        if let recordIndex = index {
//            var newInterviewCKRecordnames = self.interviewCKRecordNames
//            newInterviewCKRecordnames?.remove(at: recordIndex)
//            self.interviewCKRecordNames = newInterviewCKRecordnames
//        }
//    }
    
    func fetchProfileImage(imageCKRecordName: String, completion: @escaping (() -> Void)) {
        
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
    
    func saveProfileImage(tempImageKey: String) {
        
        if self.profileImageCKRecordName != nil {
            deleteImage(imageCKRecordName: self.profileImageCKRecordName!, completion: {
                self.saveProfileImageToCloud(tempImageKey: tempImageKey)
            })
        }
        else {
            saveProfileImageToCloud(tempImageKey: tempImageKey)
        }
    }
    
    func fetchResumeImage(imageCKRecordName: String, completion: @escaping (() -> Void)) {
        
        let imageCKRecordID = CKRecordID(recordName: imageCKRecordName)
        publicDatabase.fetch(withRecordID: imageCKRecordID) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                if let imageAsset = record.object(forKey: "image") as? CKAsset {
                    let imageData = try? Data(contentsOf: URL(fileURLWithPath: imageAsset.fileURL.path))
                    self.resumeImage = UIImage(data: imageData!)
                }
                completion()
            }
        }
    }
    
    func saveResumeImage(tempImageKey: String, completion: @escaping (() -> Void)) {
        
        if self.resumeImageCKRecordName != nil {
            deleteImage(imageCKRecordName: self.resumeImageCKRecordName!, completion: {
                self.saveResumeImageToCloud(tempImageKey: tempImageKey, completion: { 
                    completion()
                })
            })
        }
        else {
            saveResumeImageToCloud(tempImageKey: tempImageKey, completion: { 
                completion()
            })
        }
    }
    
    func saveResumePDF(url: URL) {
        
        let document = CGPDFDocument(url as CFURL)
        let page = document?.page(at: 1)
        
        let pageRect = page?.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: (pageRect?.size)!)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect!)
            
            ctx.cgContext.translateBy(x: 0.0, y: (pageRect?.size.height)!);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            
            ctx.cgContext.drawPDFPage(page!);
        }
        
        self.resumeImage = img
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
                self.fetchSpotlights()
            }
        }
    }
    
    func fetchWithFirebaseUID(firebaseUID: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let query = CKQuery(recordType: "IndividualProfile", predicate: NSPredicate(format: "firebaseUID = %@", firebaseUID))
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
        
        if let resumeImageCKRecordName = self.resumeImageCKRecordName {
            let resumeImageCKRecordID = CKRecordID(recordName: resumeImageCKRecordName)
            publicDatabase.delete(withRecordID: resumeImageCKRecordID, completionHandler: { (recordID, error) in
                if let error = error {
                    print(error)
                }
            })
        }
        
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
                self.createNewInterviewSubscription()
                completion()
            })
        }
    }
}
