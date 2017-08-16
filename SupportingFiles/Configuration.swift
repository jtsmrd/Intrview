//
//  ConfigurationNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/6/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit

class Configuration {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var appWebsiteURL: String?
    var privacyPolicyURL: String?
    var supportEmail: String?
    
    init() {
        
    }
    
    func populate() {
        
        let query = CKQuery(recordType: "Configuration", predicate: NSPredicate(format: "TRUEPREDICATE"))
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error)
            }
            else if let records = records {
                if !records.isEmpty {
                    self.appWebsiteURL = records.first?.value(forKey: "appWebsiteUrl") as? String
                    self.privacyPolicyURL = records.first?.value(forKey: "privacyPolicyUrl") as? String
                    self.supportEmail = records.first?.value(forKey: "supportEmail") as? String
                }
            }
        }
    }
}
