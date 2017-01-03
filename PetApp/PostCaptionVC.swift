//
//  PostCaptionVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/2/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper


class PostCaptionVC: UIViewController, UITextViewDelegate {
    
    var profileImg: String!
    var currentUsername: String!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        PostVC.imageSelected = true
        performSegue(withIdentifier: "toPostVC", sender: nil)
    }
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBAction func savePostTapped(_ sender: AnyObject) {
        self.saveBtn.isEnabled = false
        self.backBtn.isEnabled = false
        self.captionTextView.isEditable = false
        
        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
        
        if let imgData = UIImagePNGRepresentation(img){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            DataService.ds.REF_POST_IMGS.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to upload image to Firebase")
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
        PostVC.imageToPassBackCache.removeAllObjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextView.text = "Write a caption..."
        captionTextView.textColor = UIColor.lightGray
        captionTextView.delegate = self

        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
            self.postImage.image = img
            PostVC.imageToPassBackCache.setObject(img, forKey: "imageToPassBack")
        } else if let img2 = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
            self.postImage.image = img2
            PostVC.imageToPassBackCache.setObject(img2, forKey: "imageToPassBack")
        }
    
        
        DataService.ds.REF_CURRENT_USER.child("user-info").observe( .value, with:  { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    print("BEKAH: \(currentUser)")
                    self.currentUsername = currentUser as String!
                }
                if let profileImgUrl = dictionary["profileImgUrl"] as? String {
                    self.profileImg = profileImgUrl as String!
                }
            }
        })

    }
    
    func postToFirebase(imageURL: String) {
        if self.captionTextView.text == "Write a caption..." {
            self.captionTextView.text = ""
        }
        
        let post: Dictionary<String, Any> = [
            "caption": self.captionTextView.text! as String,
            "username": self.currentUsername as String,
            "imageURL": imageURL as String,
            "likes": 0 as Int,
            "profileImgUrl": self.profileImg,
            "comments": "" as String,
            "commentCount": 0 as Int,
            "postKey": "" as String,
            "userKey": KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        print("POST KEY: \(firebasePost.key)")
        let key = firebasePost.key
        firebasePost.updateChildValues(["postKey": key])
    }
}
