//
//  InterviewTemplateNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/5/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class InterviewTemplate {
    
    // MARK: Constants
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    // MARK: Variables
    
    var cKRecordName: String?
    var jobDescription: String?
    var jobTitle: String?
    var displayOrder: Int = 0
    var interviewQuestions = [InterviewQuestion]()
    
    // MARK: Initializers
    
    /// Default initializer
    init() {
        
    }
    
    init(with cloudKitRecord: CKRecord) {
        
        populate(with: cloudKitRecord)
    }
    
    // MARK: Private Functions
    
    private func populate(with cKRecord: CKRecord) {
        
        self.cKRecordName = cKRecord.recordID.recordName
        self.jobDescription = cKRecord.value(forKey: "jobDescription") as? String
        self.jobTitle = cKRecord.value(forKey: "jobTitle") as? String
        self.displayOrder = (cKRecord.value(forKey: "displayOrder") as? Int)!
        
        let questionsData = cKRecord.value(forKey: "questionsData") as? String
        
        if let data = questionsData {
            self.interviewQuestions.removeAll()
            self.createInterviewQuestionObjectsFromDictionaryString(questionsDictionaryString: data)
        }
    }
    
    private func fetch(with cKRecordName: String, completion: @escaping ((CKRecord?, Error?) -> Void)) {
        
        let interviewTemplateCKRecordID = CKRecordID(recordName: cKRecordName)
        publicDatabase.fetch(withRecordID: interviewTemplateCKRecordID) { (record, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let record = record {
                completion(record, nil)
            }
        }
    }
    
    private func create(with businessProfileCKRecordName: String, completion: @escaping (() -> Void)) {
        
        let newRecord = CKRecord(recordType: "InterviewTemplate")
        
        let businessProfileCKRecordID = CKRecordID(recordName: businessProfileCKRecordName)
        let businessProfileReference = CKReference(recordID: businessProfileCKRecordID, action: .none)
        newRecord.setObject(businessProfileReference, forKey: "businessProfile")
        
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
        
        record.setValue(self.jobTitle, forKey: "jobTitle")
        record.setValue(self.jobDescription, forKey: "jobDescription")
        record.setValue(self.displayOrder, forKey: "displayOrder")
        
        if interviewQuestions.count > 0 {
            let interviewQuestionsString = createInterviewQuestionsData()
            record.setValue(interviewQuestionsString, forKey: "questionsData")
        }
        
        return record
    }
    
    private func createInterviewQuestionsData() -> String {
        
        var interviewQuestionsDictionary = [String: [String: AnyObject]]()
        
        for i in 0..<interviewQuestions.count {
            interviewQuestionsDictionary["\(i)"] = [String: AnyObject]()
            interviewQuestionsDictionary["\(i)"]!["Question"] = interviewQuestions[i].question as AnyObject?
            interviewQuestionsDictionary["\(i)"]!["TimeLimit"] = interviewQuestions[i].timeLimitInSeconds as AnyObject?
            interviewQuestionsDictionary["\(i)"]!["DisplayOrder"] = interviewQuestions[i].displayOrder as AnyObject?
        }
        
        let dictionaryString = Global.convertDictionaryToString(interviewQuestionsDictionary as [String : AnyObject])
        return dictionaryString
    }
    
    func updateWithInterviewDetailsDictionaryString(_ data: String) {
        
        let dataDictionary = Global.convertStringToDictionary(data)
        jobTitle = dataDictionary!["InterviewTitle"] as? String
        jobDescription = dataDictionary!["InterviewDescription"] as? String
        createInterviewQuestionObjectsFromDictionaryString(questionsDictionaryString: data)
    }
    
    func createInterviewQuestionObjectsFromDictionaryString(questionsDictionaryString: String) {
        
        var questionsDictionary = Global.convertStringToDictionary(questionsDictionaryString)
        
        if (questionsDictionary?.keys.contains("Questions") == true) {
            questionsDictionary = questionsDictionary!["Questions"] as? [String: AnyObject]
        }
        
        interviewQuestions.removeAll()
        
        if let questionsCount = questionsDictionary?.keys.count {
            for i in 0..<questionsCount {
                
                let interviewQuestion = InterviewQuestion()
                interviewQuestion.question = questionsDictionary!["\(i)"]!["Question"] as? String
                
                interviewQuestion.timeLimitInSeconds = questionsDictionary!["\(i)"]!["TimeLimit"] as? Int
                interviewQuestion.displayOrder = questionsDictionary!["\(i)"]!["DisplayOrder"] as? Int
                
                interviewQuestions.append(interviewQuestion)
            }
        }
    }
    
    // MARK: Public Functions
    
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
        
        if let recordName = self.cKRecordName {
            
            let interviewTemplateRecordID = CKRecordID(recordName: recordName)
            publicDatabase.delete(withRecordID: interviewTemplateRecordID) { (recordID, error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func save(with businessProfileCKRecordName: String, completion: @escaping (() -> Void)) {
        
        if let recordName = self.cKRecordName {
            
            update(cKRecordName: recordName, completion: {
                completion()
            })
        }
        else {
            create(with: businessProfileCKRecordName, completion: { 
                completion()
            })
        }
    }
    
    func createDefaultTemplate() {
        
        jobTitle = "Example Template"
        jobDescription = "This is an example job description.\n\nSummary of position:\n\nJob Duties:\n\nRequired Skills:"
        
        let q1 = InterviewQuestion()
        q1.displayOrder = 0
        q1.timeLimitInSeconds = 20
        q1.question = "This is the first interview question.\nIt is \(String(describing: q1.timeLimitInSeconds!)) seconds long."
        
        let q2 = InterviewQuestion()
        q2.displayOrder = 1
        q2.timeLimitInSeconds = 45
        q2.question = "This is the second interview question.\nIt is \(String(describing: q2.timeLimitInSeconds!)) seconds long."
        
        let q3 = InterviewQuestion()
        q3.displayOrder = 2
        q3.timeLimitInSeconds = 30
        q3.question = "This is the third interview question.\nIt is \(String(describing: q3.timeLimitInSeconds!)) seconds long."
        
        interviewQuestions.append(q1)
        interviewQuestions.append(q2)
        interviewQuestions.append(q3)
    }
}
