//
//  Global.swift
//  SnapInterview
//
//  Created by JT Smrdel on 8/19/16.
//  Copyright © 2016 SmrdelJT. All rights reserved.
//

import Foundation
import UIKit

class Global {
    
    // Configuration
    static var configuration: Configuration!
    static let greenColor = UIColor(red: 0, green: (162/255), blue: (4/255), alpha: 1)
    static let grayColor = UIColor(red: (85/255), green: (85/255), blue: (85/255), alpha: 1)
    static let redColor = UIColor(red: (255/255), green: (1/255), blue: (16/255), alpha: 1)
    static let defaultBorderColor = UIColor(red: (150/255), green: (150/255), blue: (150/255), alpha: 1)
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let dayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let hoursDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh"
        return formatter
    }()
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency        
        return formatter
    }()
    
    static func iCloudContainerIsAvailable() -> Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    static func convertDictionaryToString(_ dictionary: [String:AnyObject]) -> String {
        
        var dictionaryString: String!
        do {
            let theJSONData = try JSONSerialization.data(
                withJSONObject: dictionary, options: JSONSerialization.WritingOptions(rawValue: 0))
            
            dictionaryString = NSString(data: theJSONData,
                                        encoding: String.Encoding.ascii.rawValue)! as String
        }
        catch let error as NSError {
            Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
        }
        return dictionaryString
    }
    
    static func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch let error as NSError {
                Logger.logError("Function: \(#file).\(#function) Error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    static func createInterviewQuestionsData(_ interviewQuestions: [InterviewQuestion]) -> String {
        
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
    
    static func drawLines(_ view: UIView) -> [CAShapeLayer] {
        
        var layers = [CAShapeLayer]()
        
        for view in view.subviews {
            if view.isKind(of: UITextField.self) || view.isKind(of: UITextView.self) {
                let start = CGPoint(x: view.frame.origin.x - 10, y: view.frame.origin.y + view.frame.size.height)
                let end = CGPoint(x: start.x + view.frame.size.width , y: start.y)
                
                let path = UIBezierPath()
                path.move(to: start)
                path.addLine(to: end)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.strokeColor = (UIApplication.shared.delegate as? AppDelegate)?.textTintColor.cgColor
                shapeLayer.lineWidth = 0.5
                shapeLayer.path = path.cgPath
                layers.append(shapeLayer)
                
                let start2 = CGPoint(x: view.frame.origin.x - 10, y: view.frame.origin.y + 4)
                let end2 = CGPoint(x: start2.x, y: start2.y + (view.frame.size.height) - 4)
                
                let path2 = UIBezierPath()
                path2.move(to: start2)
                path2.addLine(to: end2)
                
                let shapeLayer2 = CAShapeLayer()
                shapeLayer2.strokeColor = (UIApplication.shared.delegate as? AppDelegate)?.textTintColor.cgColor
                shapeLayer2.lineWidth = 0.5
                shapeLayer2.path = path2.cgPath
                layers.append(shapeLayer2)
            }
        }
        return layers
    }
}
