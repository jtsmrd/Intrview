//
//  SpotlightCollection.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/10/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class SpotlightCollection {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var spotlights = [Spotlight]()
    
    init() {
        
    }
    
    func fetchAllSpotlights(with cKRecordName: String, profileType: ProfileType, completion: @escaping (() -> Void)) {
        
        var predicate: NSPredicate!
        
        if profileType == ProfileType.Business {
            predicate = NSPredicate(format: "businessProfileCKRecordName = %@ AND businessDeleteFlag = %d", cKRecordName, 0)
        }
        else if profileType == ProfileType.Individual {
            predicate = NSPredicate(format: "individualProfileCKRecordName = %@ AND individualDeleteFlag = %d", cKRecordName, 0)
        }
        
        let query = CKQuery(recordType: "Spotlight", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
                completion()
            }
            else if let records = records {
                self.spotlights.removeAll()
                
                if !records.isEmpty {
                    for record in records {
                        let spotlight = Spotlight(with: record)
                        
                        // If create date is > 7 days, delete
                        if (spotlight.createDate?.addingTimeInterval((60 * 60 * 24 * 7)))! < Date() {
                            spotlight.delete()
                        }
                        else {
                            self.spotlights.append(spotlight)
                        }
                    }
                }
                completion()
            }
        }
    }
}
