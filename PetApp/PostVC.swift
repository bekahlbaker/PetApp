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
import SwiftKeychainWrapper

class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imageToFilter: UIImageView!
    @IBOutlet weak var imagePicker: UIButton!
    @IBAction func imagePickerTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
            self.postImagePicker.allowsEditing = true
            self.postImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.postImagePicker, animated: true, completion: nil)
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
            self.postImagePicker.allowsEditing = true
            self.postImagePicker.sourceType = .photoLibrary
            self.present(self.postImagePicker, animated: true, completion: nil)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
        }
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    @IBOutlet weak var addImageBtn: UIButton!
    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        if self.imageSelected == true {
            let alert = UIAlertController(title: nil, message: "If you cancel now, your image edits will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
            let discardPost = UIAlertAction(title: "Discard Post", style: .destructive, handler: { (_) -> Void in
                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            }
            alert.addAction(discardPost)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    var postImagePicker: UIImagePickerController!
    var imageSelected: Bool!
    var unFilteredImageCache: NSCache<NSString, UIImage> = NSCache()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageSelected = false
        self.addImageBtn.setTitle("Add Image", for: .normal)
        postImagePicker = UIImagePickerController()
        postImagePicker.delegate = self
        captionTextView.delegate = self
        captionTextView.text = "Write a caption..."
        captionTextView.textColor = UIColor.lightGray
        getUserInfo()
        self.captionTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.captionTextView.layer.borderWidth = 0.5
        self.originalTopConstraint = self.topConstraint.constant
    }
    var profileImg: String!
    var currentUsername: String!
    var userKeys = [String]()
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func saveBtnTapped(_ sender: Any) {
        if KeychainWrapper.standard.string(forKey: KEY_UID)! as String != "v2PvUj0ddqVe0kJRoeIWtVZR9dj1" {
            if self.imageSelected == true {
                self.activityIndicator.startAnimating()
                self.saveBtn.isEnabled = false
                self.captionTextView.isEditable = false
                DispatchQueue.global().async {
                    self.saveImageToFireBase()
                }
            } else {
                let alert = UIAlertController(title: nil, message: "Please choose a photo ", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okay)
                present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "You cannot create new posts while viewing as a guest.", message: "Please log out and create your own account.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    func getUserInfo() {
        DataService.ds.REF_CURRENT_USER.child("user-info").observe( .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.currentUsername = currentUser as String!
                }
                if let profileImgUrl = dictionary["profileImgUrl"] as? String {
                    self.profileImg = profileImgUrl as String!
                }
            }
        })
    }
    func postToFirebase(_ imageURL: String) {
        if self.captionTextView.text == "Write a caption..." {
            self.captionTextView.text = ""
        }
        let post: [String: Any] = [
            "caption": self.captionTextView.text! as String,
            "username": self.currentUsername as String,
            "imageURL": imageURL as String,
            "likes": 0 as Int,
            "profileImgUrl": self.profileImg ?? "",
            "postKey": "" as String,
            "userKey": KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        ]
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        let key = firebasePost.key
        firebasePost.updateChildValues(["postKey": key])
        self.postToFollowersWall(key: key)
        DataService.ds.REF_CURRENT_USER.child("posts").updateChildValues([key: true])
    }
    func saveImageToFireBase() {
        if let img = self.imageToFilter.image {
            if let imgData = UIImageJPEGRepresentation(img, 0.5) {
                let imgUid = NSUUID().uuidString
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/png"
                DataService.ds.REF_POST_IMGS.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("Unable to upload image to Firebase")
                    } else {
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        if let url = downloadUrl {
                            self.postToFirebase(url)
                            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                        }
                    }
                }
            }
        } else {
            print("Couldn't find image")
        }
    }
    func postToFollowersWall(key: String) {
        DataService.ds.REF_CURRENT_USER.child("followers").observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("No followers")
            } else {
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        print(snap.key)
                        self.userKeys.append(snap.key)
                    }
                }
            }
            for i in 0..<self.userKeys.count {
                DataService.ds.REF_USERS.child(self.userKeys[i]).child("wall").updateChildValues([key: true])
            }
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeedVC" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
        }
    }
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var originalTopConstraint: CGFloat!
    var keyBoardActive = false
}
