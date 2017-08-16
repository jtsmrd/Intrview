//
//  ResumeEditVC.swift
//  SnapInterview
//
//  Created by JT Smrdel on 1/17/17.
//  Copyright © 2017 SmrdelJT. All rights reserved.
//

import UIKit

class ResumeEditVC: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addReplaceResumeButton: CustomButton!
    @IBOutlet weak var viewResumeButton: CustomButton!
    
    let imageStore = ImageStore()
    
    var profile = (UIApplication.shared.delegate as! AppDelegate).profile
    var resumeImage: UIImage?
    var resumeName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))
        saveBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(backButtonAction))
        backBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let resumeName = profile.individualProfile?.resumeName, let resumeImage = profile.individualProfile?.resumeImage {
            self.resumeName = resumeName
            self.resumeImage = resumeImage
            
            addReplaceResumeButton.setTitle("Replace Resume", for: .normal)
        }
        else if resumeImage == nil {
            viewResumeButton.isHidden = true
        }
        
        infoLabel.text = self.resumeName
    }

    @objc func saveButtonAction() {
        
        if let image = self.resumeImage {
            profile.individualProfile?.resumeImage = image
            profile.individualProfile?.resumeName = self.resumeName
            
            let imageKey = UUID().uuidString
            imageStore.setImage(image, forKey: imageKey)
            
            profile.individualProfile?.saveResumeImage(tempImageKey: imageKey, completion: {
                self.profile.save()
            })
        }
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonAction() {        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addReplaceResumeButtonAction(_ sender: Any) {
        selectResume()
    }
    
    @IBAction func viewResumeButtonAction(_ sender: Any) {
        
        let viewImageVC = ViewImageVC()
        viewImageVC.image = self.resumeImage
        present(viewImageVC, animated: true, completion: nil)
    }
    
    func selectResume() {
        
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.text", "public.item"], in: .import)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }
    
    func convertPDFToImage(url: URL) {
        
        let document = CGPDFDocument(url as CFURL)
        let page = document?.page(at: 1)
        
        let pageRect = page?.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: (pageRect?.size)!)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect!)
            
            ctx.cgContext.translateBy(x: 0.0, y: (pageRect?.size.height)!)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page!)
        }
        
        resumeImage = img
    }
    
    // MARK: UIDocumentPickerDelegate Functions
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        convertPDFToImage(url: url)
        self.resumeName = url.lastPathComponent
        self.viewResumeButton.isHidden = false
        self.infoLabel.text = self.resumeName
        self.addReplaceResumeButton.setTitle("Replace Resume", for: .normal)
    }
}
