//
//  ImageViewZoomVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/26/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class ImageViewZoomVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        
        scrollView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        scrollView.contentSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
        
        view.isUserInteractionEnabled = true
        
        let dismissButton = UIButton()
        dismissButton.setAttributedTitle(NSAttributedString(string: "X", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 24), NSForegroundColorAttributeName : UIColor.lightGray]), for: .normal)
        dismissButton.frame = CGRect(x: 20, y: 35, width: 30, height: 30)
        dismissButton.titleLabel?.textAlignment = .center
        dismissButton.addTarget(self, action: #selector(dismissButtonAction), for: .allTouchEvents)
        
        view.backgroundColor = UIColor.black
        view.addSubview(dismissButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: view.bounds.size)
    }
    
    @objc func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func updateConstraintsForSize(size: CGSize) {
        
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
    }
}

extension ImageViewZoomVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
    }
}
