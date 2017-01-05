//
//  PostVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import CoreImage

class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingLbl: UILabel!
    
    @IBOutlet weak var filterScrollView: UIScrollView!
    
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imageToFilter: UIImageView!
    
    @IBAction func camerBtnTapped(_ sender: AnyObject) {
        postImagePicker.allowsEditing = true
        postImagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(postImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func libraryBtnTapped(_ sender: AnyObject) {
        postImagePicker.allowsEditing = true
        postImagePicker.sourceType = .photoLibrary
        present(postImagePicker, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var imagePicker: UIButton!
    @IBAction func imagePickerTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            print("Camera Button Pressed")
            self.postImagePicker.allowsEditing = true
            self.postImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.postImagePicker, animated: true, completion: nil)
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            print("Photo Library Button Pressed")
            self.postImagePicker.allowsEditing = true
            self.postImagePicker.sourceType = .photoLibrary
            self.present(self.postImagePicker, animated: true, completion: nil)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)

    }
    @IBOutlet weak var addImageBtn: UIButton!
    
    @IBAction func nextBtnTapped(_ sender: AnyObject) {
        if filterChosen == true {
            PostVC.filteredImageCache.setObject(imageToFilter.image!, forKey: "imageToPass")
        } else {
            PostVC.filteredImageCache.setObject(originalImage.image!, forKey: "imageToPass")
        }
        if PostVC.imageSelected == true {
            performSegue(withIdentifier: "toPostCaptionVC", sender: nil)
        } else {
            let alert = UIAlertController(title: "Please select a picture", message: "", preferredStyle: UIAlertControllerStyle.alert);
            let ok = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(ok)
            show(alert, sender: self)
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        if PostVC.imageSelected == true {
            let alert = UIAlertController(title: nil, message: "If you cancel now, your image edits will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
            let discardPost = UIAlertAction(title: "Discard Post", style: .destructive, handler: { (action) -> Void in
                PostVC.imageToPassBackCache.removeAllObjects()
                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel Button Pressed")
            }
            
            alert.addAction(discardPost)
            alert.addAction(cancel)
            
            show(alert, sender: nil)
        } else {
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }

    var postImagePicker: UIImagePickerController!
    static var imageSelected: Bool!
    static var unFilteredImageCache: NSCache<NSString, UIImage> = NSCache()
    static var filteredImageCache: NSCache<NSString, UIImage> = NSCache()
    static var imageToPassBackCache: NSCache<NSString, UIImage> = NSCache()
    var filterChosen = false
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    var myActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingLbl.isHidden = true
        self.activitySpinner.stopAnimating()
        
        PostVC.imageSelected = false
        
        myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        
        self.loadImage()

        postImagePicker = UIImagePickerController()
        postImagePicker.delegate = self
    }
    
    func loadImage() {
        if let img = PostVC.imageToPassBackCache.object(forKey: "imageToPassBack") {
            originalImage.image = img
            PostVC.imageSelected = true
            if let unfilteredImg = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
               self.addFiltersToButtons(imageUnfiltered: unfilteredImg)
            }
        } else {
            addImageBtn.setTitle("Add Image", for: .normal)
        }
        PostVC.imageToPassBackCache.removeObject(forKey: "imageToPassBack")
    }
}
