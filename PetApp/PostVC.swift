//
//  PostVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import CoreImage

class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var captionTextField: UITextView!
    
    
    @IBOutlet weak var filterScrollView: UIScrollView!
    
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imageToFilter: UIImageView!
    
    @IBAction func imagePickerTapped(_ sender: AnyObject) {
        present(postImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePost(_ sender: AnyObject) {
        
        guard let img = imageToFilter.image, imageSelected == true else {
            print("Please choose an image")
            return
        }
        
        if let imgData = UIImagePNGRepresentation(img){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            DataService.ds.REF_POST_IMGS.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to image to Firebase")
                } else {
                    print("Successfully uploaded image to Firebase")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imageURL: url)
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                    }
                }
                
            }
            
        }

        }
    
    var postImagePicker: UIImagePickerController!
    var imageSelected = false
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
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
        
        postImagePicker = UIImagePickerController()
        postImagePicker.delegate = self
        postImagePicker.allowsEditing = true
        
//        context = CIContext()
//        currentFilter = CIFilter(name: "CIPhotoEffectChrome")
        
//        var xCoord: CGFloat = 5
//        let yCoord: CGFloat = 5
//        let buttonWidth:CGFloat = 70
//        let buttonHeight: CGFloat = 70
//        let gapBetweenButtons: CGFloat = 5
//        
//        var itemCount = 0
        
//        for i in 0..<CIFilterNames.count {
//            itemCount = i
//            
//            // Button properties
//            let filterButton = UIButton(type: .custom)
//            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
//            filterButton.tag = itemCount
//            filterButton.addTarget(self, action: #selector(PostVC.filterButtonTapped(sender:)), for: .touchUpInside)
//            filterButton.layer.cornerRadius = 6
//            filterButton.clipsToBounds = true
//            
//            // CODE FOR FILTERS WILL BE ADDED HERE...
//            
//            // Create filters for each button
//            let ciContext = CIContext(options: nil)
//            let coreImage = CIImage(image: originalImage.image!)
//            let filter = CIFilter(name: "\(CIFilterNames[i])" )
//            filter!.setDefaults()
//            filter!.setValue(coreImage, forKey: kCIInputImageKey)
//            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
//            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
//            let imageForButton = UIImage(cgImage: filteredImageRef!);
//            
//            // Assign filtered image to the button
//            filterButton.setBackgroundImage(imageForButton, for: .normal)
//            
//            // Add Buttons in the Scroll View
//            xCoord +=  buttonWidth + gapBetweenButtons
//            filterScrollView.addSubview(filterButton)
//        } // END FOR LOOP
        
        
//        // Resize Scroll View
//        filterScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height: yCoord)
        
    }
    
    func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton
        
        imageToFilter.image = button.backgroundImage(for: UIControlState.normal)
    }
    
    func addFiltersToButtons() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(PostVC.filterButtonTapped(sender:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            
            // CODE FOR FILTERS WILL BE ADDED HERE...
            
            // Create filters for each button
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: originalImage.image!)
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            
            // Assign filtered image to the button
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            
            // Add Buttons in the Scroll View
            xCoord +=  buttonWidth + gapBetweenButtons
            filterScrollView.addSubview(filterButton)
        } // END FOR LOOP
        
        // Resize Scroll View
        filterScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height: yCoord)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            originalImage.image = image
            imageSelected = true
//            currentImage = image
//            
//            let beginImage = CIImage(image: currentImage)
//            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//            
//            applyProcessing()
        } else {
            print("Valid image not selected.")
        }
        picker.dismiss(animated: true, completion: nil)
        self.addFiltersToButtons()
    }
    
//    func applyProcessing() {
////        currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
//        
//        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
//            let processedImage = UIImage(cgImage: cgimg)
//            postImage.image = processedImage
//        }
//    }
    
    func postToFirebase(imageURL: String) {
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    print("BEKAH: \(currentUser)")
                    let profileImgUrl = dictionary["profileImgUrl"]
    
                    let post: Dictionary<String, Any> = [
                    "caption": self.captionTextField.text! as String,
                    "username": currentUser as String,
                    "imageURL": imageURL as String,
                    "likes": 0 as Int,
                    "profileImgUrl": profileImgUrl as! String
                    ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        self.captionTextField.text = ""
        self.imageSelected = false
        self.originalImage.image = UIImage(named: "add-image")
        
        print("POST: \(post)")
                    
                }
            }
        })
        

    }

}
