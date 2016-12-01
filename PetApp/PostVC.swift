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
        
    }
    
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
