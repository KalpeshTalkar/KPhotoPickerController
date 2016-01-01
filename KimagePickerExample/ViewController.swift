//
//  ViewController.swift
//  KimagePickerExample
//
//  Created by Kalpesh Talkar on 01/01/16.
//  Copyright © 2016 Kalpesh Talkar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KPhotoPickerDelegate {

    @IBOutlet weak var selectPhotosBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectPhotosBtn.layer.cornerRadius = 3
        selectPhotosBtn.layer.shadowColor = UIColor.darkGrayColor().CGColor
        selectPhotosBtn.layer.shadowOffset = CGSizeMake(0, 1)
        selectPhotosBtn.layer.shadowOpacity =  0.5
        selectPhotosBtn.layer.shadowRadius = 3
        
    }

    @IBAction func selectPhotos(sender: UIButton) {
        // Initialize photo picker controller
        let photoPicker = KPhotoPickerController.init()
        photoPicker.pickerDelegate = self // set picker delegate
        
        // Present photo picker modally
        self.presentViewController(photoPicker, animated: true, completion: nil);
    }
    
    // MARK - KPhotoPickerControllerDelegate
    func kPhotoPickerController(didFinishSelectingPhotos photos: [UIImage]) {
        print("total pics selected: \(photos.count)")
    }

}

