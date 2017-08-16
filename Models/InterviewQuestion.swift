//
//  InterviewQuestionNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/5/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class InterviewQuestion {
    
    var question: String?
    var timeLimitInSeconds: Int?
    var displayOrder: Int?
    
    init() {
        
    }
    
    init(question: String, timeLimitInSeconds: Int, displayOrder: Int) {
        
        self.question = question
        self.timeLimitInSeconds = timeLimitInSeconds
        self.displayOrder = displayOrder
    }
}
