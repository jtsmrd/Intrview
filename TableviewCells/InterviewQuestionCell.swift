//
//  InterviewQuestionCell.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/18/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol InterviewQuestionCellDelegate {
    func editInterviewQuestion(interviewQuestion: InterviewQuestion)
}

class InterviewQuestionCell: UITableViewCell {

    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var interviewQuestionLabel: UILabel!
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var interviewQuestion: InterviewQuestion!
    var delegate: InterviewQuestionCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(interviewQuestion: InterviewQuestion, viewOnly: Bool) {
        
        self.editButton.isHidden = viewOnly
        
        self.interviewQuestion = interviewQuestion
        
        self.interviewQuestionLabel.text = interviewQuestion.question        
        self.timeLimitLabel.text = "\(String(describing: interviewQuestion.timeLimitInSeconds!)) secs"
        
        if let questionNumber = interviewQuestion.displayOrder {
            let number = questionNumber + 1
            self.questionNumberLabel.text = "Question \(number)"
        }
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editInterviewQuestion(interviewQuestion: interviewQuestion)
    }
}
