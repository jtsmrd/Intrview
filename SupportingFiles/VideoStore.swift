//
//  VideoStore.swift
//  SnapInterview
//
//  Created by JT Smrdel on 2/9/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import UIKit

class VideoStore: NSObject {

    // MARK: - Variables and Constants
    
    let cache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - Actions
    
    func videoURLForKey(_ key: String) -> URL {
        
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
    
    func setVideo(_ video: URL, forKey key: String) {
        
        cache.setObject(video as AnyObject, forKey: key as AnyObject)
        
        // Create full URL for image
        let videoURL = videoURLForKey(key)
        
        // Turn image into JPEG data
        if let data = try? Data(contentsOf: video) {
            
            // Write it to full URL
            try? data.write(to: videoURL, options: [.atomic])
        }
    }
    
    func videoForKey(_ key: String) -> Data? {
        
        if let existingVideo = cache.object(forKey: key as AnyObject) as? Data {
            return existingVideo
        }
        
        let videoURL = videoURLForKey(key)
        
        guard let videoFromDisk = try? Data(contentsOf: URL(fileURLWithPath: videoURL.path)) else {
            return nil
        }
        
        cache.setObject(videoFromDisk as AnyObject, forKey: key as AnyObject)
        return videoFromDisk
    }
    
    func deleteVideoForKey(_ key: String) {
        
        cache.removeObject(forKey: key as AnyObject)
        
        let videoURL = videoURLForKey(key)
        
        do {
            try FileManager.default.removeItem(at: videoURL)
        }
        catch let error as NSError {
            Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
        }
    }
}
