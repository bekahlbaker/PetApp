//
//  PostCaptionVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/2/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase


class PostCaptionVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "toPostVC", sender: nil)
    }
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBAction func savePostTapped(_ sender: AnyObject) {
        self.saveBtn.isEnabled = false
        self.backBtn.isEnabled = false
        
        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
        
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
        } else {
            print("Couldn't find image")
        }
        
        PostVC.filteredImageCache.removeAllObjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextView.text = "Write a caption..."
        captionTextView.textColor = UIColor.lightGray
//        captionTextView.layer.borderColor = UIColor.lightGray.cgColor
//        captionTextView.layer.borderWidth = 1.0
//        captionTextView.layer.masksToBounds = true
        captionTextView.delegate = self

        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
            self.postImage.image = img
        } else if let img2 = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
            self.postImage.image = img2
        }

    }
    
    func postToFirebase(imageURL: String) {
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    print("BEKAH: \(currentUser)")
                    let profileImgUrl = dictionary["profileImgUrl"]
                    
                    let post: Dictionary<String, Any> = [
                        "caption": self.captionTextView.text! as String,
                        "username": currentUser as String,
                        "imageURL": imageURL as String,
                        "likes": 0 as Int,
                        "profileImgUrl": profileImgUrl as! String
                    ]
                    
                    let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
                    firebasePost.setValue(post)
                }
            }
        })
        
        
    }
}
