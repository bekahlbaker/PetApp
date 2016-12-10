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
    
    @IBAction func camerBtnTapped(_ sender: AnyObject) {
        postImagePicker.allowsEditing = true
        postImagePicker.sourceType = UIImagePickerControllerSourceType.camera
//        postImagePicker.cameraCaptureMode = .Photo
//        postImagePicker.modalPresentationStyle = .FullScreen
        present(postImagePicker,
                              animated: true,
                              completion: nil)
    }
    
    @IBAction func libraryBtnTapped(_ sender: AnyObject) {
        postImagePicker.allowsEditing = true
        postImagePicker.sourceType = .photoLibrary
        present(postImagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func imagePickerTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            print("Camera Button Pressed")
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            print("Photo Library Button Pressed")
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
        if imageSelected == true {
            performSegue(withIdentifier: "toPostCaptionVC", sender: nil)
        } else {
            print("Please select an image")
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        PostVC.imageToPassBackCache.removeAllObjects()
    }

    var postImagePicker: UIImagePickerController!
    var imageSelected = false
    static var unFilteredImageCache: NSCache<NSString, UIImage> = NSCache()
    static var filteredImageCache: NSCache<NSString, UIImage> = NSCache()
    static var imageToPassBackCache: NSCache<NSString, UIImage> = NSCache()
    
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
        
        self.loadImage()

        postImagePicker = UIImagePickerController()
        postImagePicker.delegate = self
    }
    
    func loadImage() {
        if let img = PostVC.imageToPassBackCache.object(forKey: "imageToPassBack") {
            originalImage.image = img
            addFiltersToButtons(imageUnfiltered: img)
        } else {
            addImageBtn.setTitle("Add Image", for: .normal)
        }
        PostVC.imageToPassBackCache.removeObject(forKey: "imageToPassBack")
    }
}
