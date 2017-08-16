//
//  PreviousSearchCollection.swift
//  Intrview
//
//  Created by JT Smrdel on 8/11/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import Foundation

class PreviousSearchCollection {
    
    var previousSearches = [PreviousSearch]()
    
    init() {
        load()
    }
    
    // Add search
    func add(name: String, profession: String, contactEmail: String, cKRecordName: String, searchDate: Date) {
        
        let previousSearch = PreviousSearch(name: name, profession: profession, contactEmail: contactEmail, cKRecordName: cKRecordName, searchDate: searchDate)
        
        // If the record already exists, replace it. Essentially updating the search date
        if let existingSearchIndex = previousSearches.index(where: { $0.cKRecordName == cKRecordName }) {
            previousSearches.remove(at: existingSearchIndex)
        }
        
        previousSearches.append(previousSearch)
        
        // Sort by search date desc
        previousSearches.sort { (p1, p2) -> Bool in
            p1.searchDate > p2.searchDate
        }
        
        while previousSearches.count > 10 {
            let _ = previousSearches.popLast()
        }
        
        save()
    }
    
    // Remove all searches
    func clear() {
        
        previousSearches.removeAll()
        save()
    }
    
    func removeSearch(cKRecordName: String) {
        
        if let deleteIndex = previousSearches.index(where: { $0.cKRecordName == cKRecordName }) {
            previousSearches.remove(at: deleteIndex)
        }
        save()
    }
    
    // Archive searches
    func save() {
    
        let filePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("previousSearches")
        NSKeyedArchiver.archiveRootObject(previousSearches, toFile: (filePath?.path)!)
    }
    
    // Unarchive searches
    func load() {
        
        let filePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("previousSearches")
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: (filePath?.path)!) as? [PreviousSearch] {
            previousSearches = data
        }
    }
}
