//
//  BusinessProfileCellNew.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/16/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

protocol BusinessProfileCellNewDelegate {
    func editBusinessProfile()
    func viewProfileImage(image: UIImage)
}

class BusinessProfileCellNew: UITableViewCell {

    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyLocationLabel: UILabel!
    @IBOutlet weak var contactEmailTextView: UITextView!
    @IBOutlet weak var websiteTextView: UITextView!
    
    var delegate: BusinessProfileCellNewDelegate!
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var businessProfile: BusinessProfile!
    var viewOnly: Bool = false
    
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
        delegate.editBusinessProfile()
    }
    
    @objc func profileImageViewTapped() {
        
        if let image = profileImageView.image {
            delegate.viewProfileImage(image: image)
        }
    }
    
    func configureCell(businessProfile: BusinessProfile, viewOnly: Bool) {
        
        self.editButton.isHidden = viewOnly
        
        self.businessProfile = businessProfile
        
        if let name = businessProfile.name {
            companyNameLabel.text = name
            companyNameLabel.textColor = UIColor.black
        }
        else {
            companyNameLabel.text = "[ Name ]"
            companyNameLabel.textColor = Global.grayColor
        }
        
        if let location = businessProfile.location {
            companyLocationLabel.text = location
            companyNameLabel.textColor = UIColor.black
        }
        else {
            companyLocationLabel.text = "[ Location ]"
            companyNameLabel.textColor = Global.grayColor
        }
        
        if let contactEmail = businessProfile.contactEmail {
            contactEmailTextView.text = contactEmail
            contactEmailTextView.dataDetectorTypes = [.link]
            contactEmailTextView.textColor = Global.greenColor
        }
        else {
            contactEmailTextView.text = "[ Email ]"
            contactEmailTextView.dataDetectorTypes = []
            contactEmailTextView.textColor = Global.grayColor
        }
        
        if let website = businessProfile.website {
            websiteTextView.text = website
            websiteTextView.dataDetectorTypes = [.link]
            websiteTextView.textColor = Global.greenColor
        }
        else {
            websiteTextView.text = "[ Website ]"
            websiteTextView.dataDetectorTypes = []
            websiteTextView.textColor = Global.grayColor
        }
        
        if let image = businessProfile.profileImage {
            profileImageView.image = image
        }
        else if let imageCKRecordName = businessProfile.profileImageCKRecordName {
            fetchImage(imageCKRecordName: imageCKRecordName)
        }
        else {
            profileImageView.image = UIImage(named: "default_profile_image")
        }
    }
    
    private func fetchImage(imageCKRecordName: String) {
        
        businessProfile.fetchImage(imageCKRecordName: imageCKRecordName, completion: {
            DispatchQueue.main.async {
                self.profileImageView.image = self.businessProfile.profileImage!
            }
        })
    }
}
