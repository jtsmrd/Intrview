//
//  PreviousSearch.swift
//  Intrview
//
//  Created by JT Smrdel on 8/11/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import Foundation

class PreviousSearch: NSObject, NSCoding {
    
    var name: String
    var profession: String
    var contactEmail: String
    var cKRecordName: String
    var searchDate: Date
    
    init(name: String, profession: String, contactEmail: String, cKRecordName: String, searchDate: Date) {
        
        self.name = name
        self.profession = profession
        self.contactEmail = contactEmail
        self.cKRecordName = cKRecordName
        self.searchDate = searchDate
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(profession, forKey: "profession")
        aCoder.encode(contactEmail, forKey: "contactEmail")
        aCoder.encode(cKRecordName, forKey: "cKRecordName")
        aCoder.encode(searchDate, forKey: "searchDate")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let profession = aDecoder.decodeObject(forKey: "profession") as! String
        let contactEmail = aDecoder.decodeObject(forKey: "contactEmail") as! String
        let cKRecordName = aDecoder.decodeObject(forKey: "cKRecordName") as! String
        let searchDate = aDecoder.decodeObject(forKey: "searchDate") as! Date
        
        self.init(name: name, profession: profession, contactEmail: contactEmail, cKRecordName: cKRecordName, searchDate: searchDate)
    }
}
