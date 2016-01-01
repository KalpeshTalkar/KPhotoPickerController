//
//  TableViewController.swift
//  Easy Digital
//
//  Created by Kalpesh on 07/11/15.
//  Copyright © 2015 Infini. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol KPhotoPickerDelegate {
    func kPhotoPickerController(didFinishSelectingPhotos photos:[UIImage])
}

class KPhotoPickerController: UINavigationController {
    
    var picker: KPhotoAlbums!
    
    var pickerDelegate: KPhotoPickerDelegate? {
        get { return picker.pickerDelegate }
        set { picker.pickerDelegate = newValue }
    }
    
    convenience init() {
        let photoPicker = KPhotoAlbums()
        self.init(rootViewController: photoPicker)
        
        picker = photoPicker
    }
}

class KPhotoAlbums: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pickerDelegate: KPhotoPickerDelegate?
    
    let assetsLibrary = ALAssetsLibrary()
    var groups = Array<ALAssetsGroup>()
    
    convenience init() {
        self.init(nibName: "KPhotoAlbums", bundle: NSBundle.mainBundle())
    }
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissImagePicker")
        self.navigationItem.rightBarButtonItem = cancelButton
        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.estimatedRowHeight = 81
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "KAlbumCell", bundle: nil), forCellReuseIdentifier: "Album")
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        let groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos
        assetsLibrary.enumerateGroupsWithTypes(groupTypes, usingBlock: { (group, stop) -> Void in
            
            if group != nil {
                let onlyPhotosFilter = ALAssetsFilter.allPhotos()
                group.setAssetsFilter(onlyPhotosFilter)
                
                if group.numberOfAssets() > 0 {
                    self.groups.append(group)
                }
            }
            self.tableView.reloadData()
            
            }) { (error) -> Void in
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Cancel Image Picker
    func dismissImagePicker() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - TableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Album", forIndexPath: indexPath) as! KAlbumCell
        
        // Configure the cell...
        let groupForCell = groups[indexPath.row]
        let posterImageRef = groupForCell.posterImage().takeUnretainedValue()
        let posterImage  = UIImage(CGImage: posterImageRef)
        
        cell.albumCover.image = posterImage
        cell.albumName.text = (groupForCell.valueForProperty(ALAssetsGroupPropertyName) as! String)
        cell.albumCount.text = "\(groupForCell.numberOfAssets())"
        
        return cell
    }
    
    
    // MARK: - TableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let albumPhotos = KAlbumPhotos()
        albumPhotos.assetsGroup = groups[indexPath.row]
        albumPhotos.pickerDelegate = pickerDelegate
        
        self.navigationController?.pushViewController(albumPhotos, animated: true)
    }
    
}

class KAlbumPhotos: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pickerDelegate: KPhotoPickerDelegate?
    
    var assetsGroup = ALAssetsGroup()
    var assets = Array<ALAsset>()
    
    convenience init() {
        self.init(nibName: "KAlbumPhotos", bundle: NSBundle.mainBundle())
    }
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSelectingImages")
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.collectionView.registerNib(UINib(nibName: "KPhotoCell", bundle: nil), forCellWithReuseIdentifier: "Photo")
        self.collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        //self.collectionView?.allowsSelection = true
        self.collectionView.allowsMultipleSelection = true
        
        self.title = (assetsGroup.valueForProperty(ALAssetsGroupPropertyName) as! String)
        
        let onlyPhotosFilter = ALAssetsFilter.allPhotos()
        assetsGroup.setAssetsFilter(onlyPhotosFilter)
        assetsGroup.enumerateAssetsUsingBlock { (result, index, stop) -> Void in
            if result != nil {
                self.assets.append(result)
            }
            self.collectionView.reloadData()
        }
    }
    
    
    // MARK: - Done Selecting Images
    func doneSelectingImages() {
        let selected = self.collectionView?.indexPathsForSelectedItems()
        
        var photos = Array<UIImage>()
        
        for indexPath in selected! {
            let asset = assets[indexPath.row]
            let assetRepresentation = asset.defaultRepresentation()
            let orientation = UIImageOrientation.Up
            let img = UIImage(CGImage: assetRepresentation.fullResolutionImage().takeUnretainedValue(), scale: 1, orientation: orientation)
            photos.append(img)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        pickerDelegate?.kPhotoPickerController(didFinishSelectingPhotos: photos)
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Photo", forIndexPath: indexPath) as! KPhotoCell
        
        // Configure the cell
        let asset = assets[indexPath.row]
        let thumbnailImageRef = asset.thumbnail().takeUnretainedValue()
        let thumbnail = UIImage(CGImage: thumbnailImageRef)
        
        cell.photo.image = thumbnail
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 100)
    }
    
}

class KAlbumCell: UITableViewCell {
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumCount: UILabel!
}

class KPhotoCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var select: UIImageView!
    
    override var selected:Bool {
        didSet {
            if selected {
                select.image = UIImage(named: "k_photo_tick")
            } else {
                select.image = nil
            }
        }
    }
}
