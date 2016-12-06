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
    
    @IBOutlet weak var captionTextField: UITextView!

    @IBOutlet weak var filterScrollView: UIScrollView!
    
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imageToFilter: UIImageView!
    
    @IBAction func imagePickerTapped(_ sender: AnyObject) {
        present(postImagePicker, animated: true, completion: nil)
        addImageBtn.setTitle("", for: .normal)
    }
    @IBOutlet weak var addImageBtn: UIButton!
    
    @IBAction func nextBtnTapped(_ sender: AnyObject) {
        if imageSelected == true {
            performSegue(withIdentifier: "toPostCaptionVC", sender: nil)
        } else {
            print("Please select an image")
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        PostVC.filteredImageCache.removeAllObjects()
        sync()
    }
    
    @IBAction func savePost(_ sender: AnyObject) {

        }
    
    var postImagePicker: UIImagePickerController!
    var imageSelected = false
    static var unFilteredImageCache: NSCache<NSString, UIImage> = NSCache()
    static var filteredImageCache: NSCache<NSString, UIImage> = NSCache()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
            originalImage.image = img
            if let unfilteredImg = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
               addFiltersToButtons(imageUnfiltered: unfilteredImg)
            }
            addImageBtn.setTitle("", for: .normal)
        } else {
            addImageBtn.setTitle("Add Image", for: .normal)
        }
        
        postImagePicker = UIImagePickerController()
        postImagePicker.delegate = self
        postImagePicker.allowsEditing = true
        
    }
}
