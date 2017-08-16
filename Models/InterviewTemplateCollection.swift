//
//  InterviewTemplateCollection.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/5/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class InterviewTemplateCollection {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var interviewTemplates = [InterviewTemplate]()
    
    init() {
        
    }
    
    func fetchAllTemplates(with businessProfileCKRecordName: String, completion: @escaping (() -> Void)) {
        
        let businessProfileCKRecordID = CKRecordID(recordName: businessProfileCKRecordName)
        let businessProfileReference = CKReference(recordID: businessProfileCKRecordID, action: .none)
        
        let query = CKQuery(recordType: "InterviewTemplate", predicate: NSPredicate(format: "businessProfile = %@", businessProfileReference))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let records = records {
                
                self.interviewTemplates.removeAll()
                if !records.isEmpty {
                    
                    for record in records {
                        let interviewTemplate = InterviewTemplate(with: record)
                        self.interviewTemplates.append(interviewTemplate)
                    }
                }
                else {
                    // Add default template
                    self.insertDefaultTemplate()
                }
                completion()
            }
        }
    }
    
    func insertDefaultTemplate() {
        
        let defaultTemplate = InterviewTemplate()
        defaultTemplate.createDefaultTemplate()
        self.interviewTemplates.append(defaultTemplate)
    }
}
