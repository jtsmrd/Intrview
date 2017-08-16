//
//  IndividualProfileCellNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/13/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol IndividualProfileCellDelegate {
    func editIndividualProfile()
    func viewProfileImage(image: UIImage)
}

class IndividualProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contactEmailTextView: UITextView!
    @IBOutlet weak var phoneNumberTextView: UITextView!
    
    var delegate: IndividualProfileCellDelegate!
    var individualProfile: IndividualProfile!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        tapGestureRecognizer.delegate = self
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate.editIndividualProfile()
    }
    
    @objc func profileImageViewTapped() {
        
        if let image = profileImageView.image {
            delegate.viewProfileImage(image: image)
        }
    }
    
    func configureCell(individualProfile: IndividualProfile, viewOnly: Bool) {
        
        self.individualProfile = individualProfile
        editButton.isHidden = viewOnly
        
        if let name = individualProfile.name {
            if !name.isEmpty {
                nameLabel.text = name
                nameLabel.textColor = UIColor.black
            }
            else {
                nameLabel.text = "[ Name ]"
                nameLabel.textColor = Global.grayColor
            }
        }
        else {
            nameLabel.text = "[ Name ]"
            nameLabel.textColor = Global.grayColor
        }
        
        if let profession = individualProfile.profession {
            if !profession.isEmpty {
                titleLabel.text = profession
                titleLabel.textColor = UIColor.black
            }
            else {
                titleLabel.text = "[ Title ]"
                titleLabel.textColor = Global.grayColor
            }
        }
        else {
            titleLabel.text = "[ Title ]"
            titleLabel.textColor = Global.grayColor
        }
        
        if let location = individualProfile.location {
            if !location.isEmpty {
                locationLabel.text = location
                locationLabel.textColor = UIColor.black
            }
            else {
                locationLabel.text = "[ Location ]"
                locationLabel.textColor = Global.grayColor
            }
        }
        else {
            locationLabel.text = "[ Location ]"
            locationLabel.textColor = Global.grayColor
        }
        
        if let contactEmail = individualProfile.contactEmail {
            if !contactEmail.isEmpty {
                contactEmailTextView.text = contactEmail
                contactEmailTextView.dataDetectorTypes = [.link]
                contactEmailTextView.textColor = Global.greenColor
            }
            else {
                contactEmailTextView.text = "[ Email ]"
                contactEmailTextView.dataDetectorTypes = []
                contactEmailTextView.textColor = Global.grayColor
            }
        }
        else {
            contactEmailTextView.text = "[ Email ]"
            contactEmailTextView.dataDetectorTypes = []
            contactEmailTextView.textColor = Global.grayColor
        }
        
        if let contactPhone = individualProfile.contactPhone {
            if !contactPhone.isEmpty {
                phoneNumberTextView.text = contactPhone
                phoneNumberTextView.dataDetectorTypes = [.phoneNumber]
                phoneNumberTextView.textColor = Global.greenColor
            }
            else {
                phoneNumberTextView.text = "[ Phone Number ]"
                phoneNumberTextView.dataDetectorTypes = []
                phoneNumberTextView.textColor = Global.grayColor
            }
        }
        else {
            phoneNumberTextView.text = "[ Phone Number ]"
            phoneNumberTextView.dataDetectorTypes = []
            phoneNumberTextView.textColor = Global.grayColor
        }
        
        if let image = individualProfile.profileImage {
            profileImageView.image = image
        }
        else if let imageCKRecordName = individualProfile.profileImageCKRecordName {
            fetchImage(imageCKRecordName: imageCKRecordName)
        }
        else {
            profileImageView.image = UIImage(named: "default_profile_image")
        }
    }
    
    private func fetchImage(imageCKRecordName: String) {
        
        individualProfile.fetchProfileImage(imageCKRecordName: imageCKRecordName, completion: {
            DispatchQueue.main.async {
                self.profileImageView.image = self.individualProfile.profileImage!
            }
        })
    }
}
