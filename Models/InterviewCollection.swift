//
//  InterviewCollection.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/6/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class InterviewCollection {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var interviews = [Interview]()
    
    init() {
        
    }
    
    func fetchAllInterviews(with cKRecordName: String, profileType: ProfileType, completion: @escaping (() -> Void)) {
        
        var predicate: NSPredicate!
        
        if profileType == ProfileType.Business {
            predicate = NSPredicate(format: "businessProfileCKRecordName = %@ AND businessDeleteFlag = %d", cKRecordName, 0)
        }
        else if profileType == ProfileType.Individual {
            predicate = NSPredicate(format: "individualProfileCKRecordName = %@ AND individualDeleteFlag = %d", cKRecordName, 0)
        }
        
        let query = CKQuery(recordType: "Interview", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let records = records {
                
                self.interviews.removeAll()
                
                if !records.isEmpty {
                    for record in records {
                        let interview = Interview(with: record)
                        
                        // If requested date is > 7 days, delete
                        if (interview.createDate?.addingTimeInterval((60 * 60 * 24 * 7)))! < Date() {
                            interview.delete()
                        }
                        else {
                            self.interviews.append(interview)
                        }
                    }
                    completion()
                }                
            }
        }
    }
    
    // Check if the selected user already has an active interview pending for the selected interview template
    func identicalPendingInterviewExists(individualProfileCKRecordName: String, interviewTemplateCKRecordName: String) -> Bool {
        
        for interview in interviews {
            if interview.individualProfileCKRecordName! == individualProfileCKRecordName {
                if interview.interviewTemplateCKRecordName! == interviewTemplateCKRecordName {
                    if interview.interviewStatus! == InterviewStatus.Pending.rawValue {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
