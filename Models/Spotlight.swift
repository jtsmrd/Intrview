//
//  Spotlight.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/10/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class Spotlight {
    
    // MARK: Constants
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let videoStore = (UIApplication.shared.delegate as! AppDelegate).videoStore
    
    // MARK: Variables
    
    var individualProfileCKRecordName: String?
    var businessProfileCKRecordName: String?
    var cKRecordName: String?
    var videoCKRecordName: String?
    var videoKey: String?
    var jobTitle: String?
    var individualName: String?
    var businessName: String?
    var viewCount: Int = 0
    var optionalQuestions = [String]()
    var businessNewFlag: Bool = false
    var individualNewFlag: Bool = false
    var businessDeleteFlag: Bool = false
    var individualDeleteFlag: Bool = false
    var createDate: Date?

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
    
    init(with cloudKitRecord: CKRecord) {
        populate(with: cloudKitRecord)
    }
    
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
    
    private func populate(with cKRecord: CKRecord) {
        
        self.cKRecordName = cKRecord.recordID.recordName
        self.individualProfileCKRecordName = cKRecord.value(forKey: "individualProfileCKRecordName") as? String
        self.businessProfileCKRecordName = cKRecord.value(forKey: "businessProfileCKRecordName") as? String
        self.videoCKRecordName = cKRecord.value(forKey: "videoCKRecordName") as? String
        self.jobTitle = cKRecord.value(forKey: "jobTitle") as? String
        self.individualName = cKRecord.value(forKey: "individualName") as? String
        self.businessName = cKRecord.value(forKey: "businessName") as? String
        self.createDate = cKRecord.object(forKey: "createDate") as? Date
        
        if let viewCount = cKRecord.value(forKey: "viewCount") as? Int {
            self.viewCount = viewCount
        }
        
        if let newFlag = cKRecord.value(forKey: "businessNewFlag") as? Int {
            businessNewFlag = Bool.init(NSNumber(integerLiteral: newFlag))
        }
        
        if let newFlag = cKRecord.value(forKey: "individualNewFlag") as? Int {
            individualNewFlag = Bool.init(NSNumber(integerLiteral: newFlag))
        }
        
        if let deleteFlag = cKRecord.value(forKey: "businessDeleteFlag") as? Int {
            businessDeleteFlag = Bool.init(NSNumber(integerLiteral: deleteFlag))
        }
        
        if let deleteFlag = cKRecord.value(forKey: "individualDeleteFlag") as? Int {
            individualDeleteFlag = Bool.init(NSNumber(integerLiteral: deleteFlag))
        }
    }
    
    private func fetch(with cKRecordName: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let spotlightCKRecordID = CKRecordID(recordName: cKRecordName)
        publicDatabase.fetch(withRecordID: spotlightCKRecordID) { (record, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let record = record {
                completion(record, nil)
            }
        }
    }
    
    private func create(completion: @escaping (() -> Void)) {
        
        let newRecord = CKRecord(recordType: "Spotlight")
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
        record.setValue(self.videoCKRecordName, forKey: "videoCKRecordName")
        record.setValue(self.jobTitle, forKey: "jobTitle")
        record.setValue(self.individualName, forKey: "individualName")
        record.setValue(self.businessName, forKey: "businessName")
        record.setValue(self.viewCount, forKey: "viewCount")
        record.setObject(self.createDate as CKRecordValue?, forKey: "createDate")
        record.setValue(Int.init(NSNumber(booleanLiteral: businessNewFlag)), forKey: "businessNewFlag")
        record.setValue(Int.init(NSNumber(booleanLiteral: individualNewFlag)), forKey: "individualNewFlag")
        record.setValue(Int.init(NSNumber(booleanLiteral: businessDeleteFlag)), forKey: "businessDeleteFlag")
        record.setValue(Int.init(NSNumber(booleanLiteral: individualDeleteFlag)), forKey: "individualDeleteFlag")
        
        return record
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
        
        let videoRecordID = CKRecordID(recordName: self.videoCKRecordName!)
        publicDatabase.delete(withRecordID: videoRecordID) { (recordID, error) in
            if let error = error {
                print(error)
            }
            else {
                let spotlightRecordID = CKRecordID(recordName: self.cKRecordName!)
                self.publicDatabase.delete(withRecordID: spotlightRecordID, completionHandler: { (recordID, error) in
                    if let error = error {
                        print(error)
                    }
                })
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
                completion()
            })
        }
    }
}
