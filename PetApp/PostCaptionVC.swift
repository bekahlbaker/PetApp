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
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBAction func savePostTapped(_ sender: AnyObject) {
        self.myActivityIndicator.startAnimating()
        self.saveBtn.isEnabled = false
        self.captionTextView.isEditable = false
        DispatchQueue.global().async {
            self.saveImageToFireBase()
        }
    }
    var myActivityIndicator: UIActivityIndicatorView!
    var isAnimating = false
    var userKeys = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextView.delegate = self
        captionTextView.text = "Write a caption..."
        captionTextView.textColor = UIColor.lightGray
        myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        getUserInfo()
    }
    override func viewDidAppear(_ animated: Bool) {
        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
            self.postImage.image = img
            PostVC.imageToPassBackCache.setObject(img, forKey: "imageToPassBack")
        } else if let img2 = PostVC.unFilteredImageCache.object(forKey: "unfilteredImage") {
            self.postImage.image = img2
            PostVC.imageToPassBackCache.setObject(img2, forKey: "imageToPassBack")
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
            "comments": "" as String,
            "commentCount": 0 as Int,
            "postKey": "" as String,
            "userKey": KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        ]
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        let key = firebasePost.key
        firebasePost.updateChildValues(["postKey": key])
        self.postToFollowersWall(key: key)
    }
    func saveImageToFireBase() {
        if let img = PostVC.filteredImageCache.object(forKey: "imageToPass") {
            if let imgData = UIImagePNGRepresentation(img) {
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
        PostVC.filteredImageCache.removeAllObjects()
        PostVC.imageToPassBackCache.removeAllObjects()
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
}
