//
//  ViewController.swift
//  KimagePickerExample
//
//  Created by Kalpesh Talkar on 01/01/16.
//  Copyright © 2016 Kalpesh Talkar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KPhotoPickerDelegate, UICollectionViewDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectPhotosBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var photosArray = Array<UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "Photos selected: 0"

        selectPhotosBtn.layer.cornerRadius = 3
        selectPhotosBtn.layer.shadowColor = UIColor.darkGrayColor().CGColor
        selectPhotosBtn.layer.shadowOffset = CGSizeMake(0, 1)
        selectPhotosBtn.layer.shadowOpacity =  0.5
        selectPhotosBtn.layer.shadowRadius = 3
        
        collectionView.backgroundColor = UIColor.clearColor()
    }

    // MARK - Button Action
    @IBAction func selectPhotos(sender: UIButton) {
        // Initialize photo picker controller
        let photoPicker = KPhotoPickerController.init()
        photoPicker.pickerDelegate = self // set picker delegate
        
        // Present photo picker modally
        self.presentViewController(photoPicker, animated: true, completion: nil);
    }
    
    // MARK - KPhotoPickerControllerDelegate
    func kPhotoPickerController(didFinishSelectingPhotos photos: [UIImage]) {
        label.text = "Photos selected: \(photos.count)"
        photosArray = photos
        collectionView.reloadData()
    }

    // MARK - CollectionView Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PictureCell
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 5
        cell.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(0, 1)
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 5
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 5
        cell.imageView.image = photosArray[indexPath.item];
        return cell;
    }
}

class PictureCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

