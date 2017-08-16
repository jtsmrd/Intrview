//
//  AppDelegate.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/28/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import UIKit
import CloudKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let imageStore = ImageStore()
    let videoStore = VideoStore()
    
    var window: UIWindow?
    var textTintColor: UIColor!
    var profile = Profile()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        if application.applicationIconBadgeNumber > 0 {
            resetBadgeCounter()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let notification = CKNotification(fromRemoteNotificationDictionary: (userInfo as? [String : AnyObject])! as! [String : NSObject])
        if notification.notificationType == .query {
            let queryNotification = notification as! CKQueryNotification
            
            if queryNotification.category == "IndividualProfileNotification" {
                
            }
            else if queryNotification.category == "IndividualProfileSpotlightViewed" {
                print("Spotlight viewed")
            }
        }
        
        completionHandler(.noData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Clear the notification badge when app is opened.
        if application.applicationIconBadgeNumber > 0 {
            resetBadgeCounter()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let config = Configuration()
        config.populate()
        Global.configuration = config
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func resetBadgeCounter() {
        
        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = { (error) -> Void in
            if error != nil {
                print("Error resetting badge: \(error!)")
            }
            else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        CKContainer.default().add(badgeResetOperation)
    }
}

