//
//  Interview.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/5/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

enum InterviewStatus: String {
    case Pending = "Pending"
    case Complete = "Complete"
    case Declined = "Declined"
}

class Interview {
    
    // MARK: Constants
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let videoStore = (UIApplication.shared.delegate as! AppDelegate).videoStore
    
    // MARK: Variables
    
    var cKRecordName: String?
    var individualProfileCKRecordName: String?
    var businessProfileCKRecordName: String?
    var createDate: Date?
    var completeDate: Date?
    var interviewStatus: String?
    var videoCKRecordName: String?
    var videoKey: String?
    var interviewDetailsData: String?
    var skippedQuestionsData: String?
    var interviewTemplate = InterviewTemplate()
    var skippedQuestions = [InterviewQuestion]()
    var interviewTemplateCKRecordName: String?
    var businessDeleteFlag: Bool = false
    var individualDeleteFlag: Bool = false
    var viewCount: Int = 0
    var businessName: String?
    var individualName: String?
    var individualNewFlag: Bool = false
    var businessNewFlag: Bool = false
    var interviewTitle: String?
    var interviewDescription: String?
    
    var daysUntilExpired: Int {
        get {
            let expireDate = createDate?.addingTimeInterval((60 * 60 * 24 * 7))
            return Calendar.current.dateComponents([.day], from: Date.init(), to: expireDate!).day!
        }
    }
    
    var hoursUntilExpired: Int {
        get {
            let expireDate = createDate?.addingTimeInterval((60 * 60 * 24 * 7))
            return Calendar.current.dateComponents([.hour], from: Date.init(), to: expireDate!).hour!
        }
    }
    
    // MARK: Initializers
    
    /// Default initializer
    init() {
        
    }
    
    /// Initialize an Interview object using a CKRecord
    ///
    /// - Parameter cloudKitRecord: CloudKit record of the Interview
    init(with cloudKitRecord: CKRecord) {
        
        populate(with: cloudKitRecord)
    }
    
    
    /// Initialize an Interview object using it's associated CKRecordName
    ///
    /// - Parameter cKRecordName: The CKRecordName of the Interview
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
        
        self.cKRecordName = cKRecord.recordID.recordName
        self.individualProfileCKRecordName = cKRecord.value(forKey: "individualProfileCKRecordName") as? String
        self.businessProfileCKRecordName = cKRecord.value(forKey: "businessProfileCKRecordName") as? String
        self.createDate = cKRecord.object(forKey: "createDate") as? Date
        self.completeDate = cKRecord.object(forKey: "completeDate") as? Date
        self.interviewStatus = cKRecord.value(forKey: "interviewStatus") as? String
        self.videoCKRecordName = cKRecord.value(forKey: "videoCKRecordName") as? String
        self.interviewDetailsData = cKRecord.value(forKey: "interviewDetailsData") as? String
        self.skippedQuestionsData = cKRecord.value(forKey: "skippedQuestionsData") as? String
        self.interviewTemplateCKRecordName = cKRecord.value(forKey: "interviewTemplateCKRecordName") as? String
        self.businessName = cKRecord.value(forKey: "businessName") as? String
        self.individualName = cKRecord.value(forKey: "individualName") as? String
        self.interviewTitle = cKRecord.value(forKey: "interviewTitle") as? String
        self.interviewDescription = cKRecord.value(forKey: "interviewDescription") as? String
        
        if let count = cKRecord.value(forKey: "viewCount") as? Int {
            self.viewCount = count
        }
        
        if let deleteFlag = cKRecord.value(forKey: "businessDeleteFlag") as? Int {
            businessDeleteFlag = Bool.init(NSNumber(value: deleteFlag))
        }
        
        if let deleteFlag = cKRecord.value(forKey: "individualDeleteFlag") as? Int {
            individualDeleteFlag = Bool.init(NSNumber(value: deleteFlag))
        }
        
        if let newFlag = cKRecord.value(forKey: "businessNewFlag") as? Int {
            businessNewFlag = Bool.init(NSNumber(value: newFlag))
        }
        
        if let newFlag = cKRecord.value(forKey: "individualNewFlag") as? Int {
            individualNewFlag = Bool.init(NSNumber(value: newFlag))
        }
        
        if let videoRecordName = self.videoCKRecordName {
            self.videoKey = videoRecordName + ".mov"
        }
        
        self.interviewTemplate.createInterviewQuestionObjectsFromDictionaryString(questionsDictionaryString: self.interviewDetailsData!)
    }
    
    private func fetch(with cKRecordName: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let interviewCKRecordID = CKRecordID(recordName: cKRecordName)
        publicDatabase.fetch(withRecordID: interviewCKRecordID) { (record, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let record = record {
                completion(record, nil)
            }
        }
    }
    
    private func create(completion: @escaping (() -> Void)) {
        
        let newRecord = CKRecord(recordType: "Interview")
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
        
        record.setValue(self.individualProfileCKRecordName, forKey: "individualProfileCKRecordName")
        record.setValue(self.businessProfileCKRecordName, forKey: "businessProfileCKRecordName")
        record.setObject(self.createDate as CKRecordValue?, forKey: "createDate")
        record.setObject(self.completeDate as CKRecordValue?, forKey: "completeDate")
        record.setValue(self.interviewStatus, forKey: "interviewStatus")
        record.setValue(self.videoCKRecordName, forKey: "videoCKRecordName")
        record.setValue(self.interviewDetailsData, forKey: "interviewDetailsData")
        record.setValue(self.skippedQuestionsData, forKey: "skippedQuestionsData")
        record.setValue(self.interviewTemplateCKRecordName, forKey: "interviewTemplateCKRecordName")
        record.setValue(Int.init(NSNumber(booleanLiteral: businessDeleteFlag)), forKey: "businessDeleteFlag")
        record.setValue(Int.init(NSNumber(booleanLiteral: individualDeleteFlag)), forKey: "individualDeleteFlag")
        record.setValue(self.viewCount, forKey: "viewCount")
        record.setValue(self.businessName, forKey: "businessName")
        record.setValue(self.individualName, forKey: "individualName")
        record.setValue(Int.init(NSNumber(booleanLiteral: businessNewFlag)), forKey: "businessNewFlag")
        record.setValue(Int.init(NSNumber(booleanLiteral: individualNewFlag)), forKey: "individualNewFlag")
        record.setValue(self.interviewTitle, forKey: "interviewTitle")
        record.setValue(self.interviewDescription, forKey: "interviewDescription")
        
        return record
    }
    
    func createInterviewDataString() {
        
        var interviewDictionary = [String: AnyObject]()
        var questionsDictionary = [String: [String: AnyObject]]()
        
        let interviewQuestions = self.interviewTemplate.interviewQuestions
        interviewDictionary["InterviewTitle"] = self.interviewTemplate.jobTitle as AnyObject?
        interviewDictionary["InterviewDescription"] = self.interviewTemplate.jobDescription as AnyObject?
        
        for i in 0 ..< interviewQuestions.count {
            questionsDictionary["\(i)"] = [String: AnyObject]()
            questionsDictionary["\(i)"]!["Question"] = interviewQuestions[i].question as AnyObject?
            questionsDictionary["\(i)"]!["TimeLimit"] = interviewQuestions[i].timeLimitInSeconds as AnyObject?
            questionsDictionary["\(i)"]!["DisplayOrder"] = interviewQuestions[i].displayOrder as AnyObject?
        }
        
        interviewDictionary["Questions"] = questionsDictionary as AnyObject?
        self.interviewDetailsData = Global.convertDictionaryToString(interviewDictionary)
    }
    
    // MARK: Public Functions
    
    func createInterviewQuestionObjectsFromDictionaryString(questionsDictionaryString: String) {
        
        var questionsDictionary = Global.convertStringToDictionary(questionsDictionaryString)
        
        if (questionsDictionary?.keys.contains("Questions") == true) {
            questionsDictionary = questionsDictionary!["Questions"] as? [String: AnyObject]
        }
        
        skippedQuestions.removeAll()
        
        if let questionsCount = questionsDictionary?.keys.count {
            for i in 0..<questionsCount {
                
                let interviewQuestion = InterviewQuestion()
                interviewQuestion.question = questionsDictionary!["\(i)"]!["Question"] as? String
                
                interviewQuestion.timeLimitInSeconds = questionsDictionary!["\(i)"]!["TimeLimit"] as? Int
                interviewQuestion.displayOrder = questionsDictionary!["\(i)"]!["DisplayOrder"] as? Int
                
                skippedQuestions.append(interviewQuestion)
            }
        }
    }
    
    func fetchVideo(videoCKRecordName: String, completion: @escaping (() -> Void)) {
        
        let videoCKRecordID = CKRecordID(recordName: videoCKRecordName)
        publicDatabase.fetch(withRecordID: videoCKRecordID) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                if let videoAsset = record.object(forKey: "video") as? CKAsset {
                    let videoURL = videoAsset.fileURL
                    self.videoKey = record.recordID.recordName + ".mov"
                    self.videoStore.setVideo(videoURL, forKey: self.videoKey!)
                    completion()
                }
            }
        }
    }
    
    func saveVideo(videoURL: URL, completion: @escaping (() -> Void)) {
        
        let videoRecord = CKRecord(recordType: "Video")
        let videoAsset = CKAsset(fileURL: videoURL)
        videoRecord.setObject(videoAsset, forKey: "video")
        
        publicDatabase.save(videoRecord) { (record, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let record = record {
                self.videoCKRecordName = record.recordID.recordName
                self.videoKey = self.videoCKRecordName! + ".mov"
                self.videoStore.setVideo(videoURL, forKey: self.videoKey!)
                completion()
            }
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
            }
        }
    }
    
    func delete() {
        
        if let videoCKRecordName = self.videoCKRecordName {
            let videoRecordID = CKRecordID(recordName: videoCKRecordName)
            publicDatabase.delete(withRecordID: videoRecordID, completionHandler: { (recordID, error) in
                if let error = error {
                    print(error)
                }
                else {
                    let recordID = CKRecordID(recordName: self.cKRecordName!)
                    self.publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
                        if let error = error {
                            print(error)
                        }
                    }
                }
            })
        }
        else {
            let recordID = CKRecordID(recordName: self.cKRecordName!)
            publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func save(completion: @escaping (() -> Void)) {
        
        self.createInterviewDataString()
        
        if let recordName = self.cKRecordName {
            update(cKRecordName: recordName, completion: {
                completion()
            })
        }
        else {
            create(completion: {
                completion()
            })
        }
    }
}
