//
//  ViewImageVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/13/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class ViewImageVC: UIViewController {

    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = true
        
        let dismissButton = UIButton()
        dismissButton.setAttributedTitle(NSAttributedString(string: "X", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 24), NSForegroundColorAttributeName : UIColor.lightGray]), for: .normal)
        dismissButton.frame = CGRect(x: 20, y: 35, width: 30, height: 30)
        dismissButton.titleLabel?.textAlignment = .center
        dismissButton.addTarget(self, action: #selector(dismissButtonAction), for: .allTouchEvents)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.frame
        
        view.backgroundColor = UIColor.black
        view.addSubview(imageView)
        view.addSubview(dismissButton)
        modalPresentationStyle = .overFullScreen
    }

    @objc func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}
