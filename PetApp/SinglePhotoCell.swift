//
//  SinglePhotoCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/13/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//
//  swiftlint:disable force_cast

import UIKit
import Firebase
import SwiftKeychainWrapper

class SinglePhotoCell: UITableViewCell {
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likesImgSm: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var captionEditTextField: UITextField!
    @IBOutlet weak var viewCommentsBtn: UIButton!
    weak var delegate: UIViewController?
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.moreBtn.isEnabled = true
        self.caption.isHidden = false
        self.captionEditTextField.isHidden = true
        self.saveBtn.isHidden = true
        self.caption.text = self.captionEditTextField.text
        DataService.ds.REF_POSTS.child(self.post.postKey).updateChildValues(["caption": "\(caption.text!)"])
    }
    @IBOutlet weak var moreBtn: UIButton!
    @IBAction func moreBtnTapped(_ sender: Any) {
        if self.isCurrentUser == false {
            let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
            let report = UIAlertAction(title: "Report", style: .destructive, handler: { (_) -> Void in
                let alert = UIAlertController(title: "Are you sure you want to report this post?", message: "This post will not appear on your feed any longer.", preferredStyle: UIAlertControllerStyle.alert)
                let deletePost = UIAlertAction(title: "Report Post", style: .destructive, handler: { (_) -> Void in
                    //Handle reporting a post
                    DataService.ds.REF_BASE.child("flagged-posts").child(KeychainWrapper.standard.string(forKey: KEY_UID)! as String).updateChildValues([self.post.postKey: true])
                    DataService.ds.REF_CURRENT_USER.child("wall").child(self.post.postKey).removeValue()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
                })
                let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                }
                alert.addAction(deletePost)
                alert.addAction(cancel)
                self.delegate?.present(alert, animated: true, completion: nil)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            })
            alertController.addAction(report)
            alertController.addAction(cancel)
            delegate?.present(alertController, animated: true, completion: nil)
        } else if self.isCurrentUser == true {
            let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
            let edit = UIAlertAction(title: "Edit", style: .default, handler: { (_) -> Void in
                self.moreBtn.isEnabled = false
                self.caption.isHidden = true
                self.captionEditTextField.isHidden = false
                self.saveBtn.isHidden = false
                self.captionEditTextField.text = self.caption.text
                self.captionEditTextField.becomeFirstResponder()
            })
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) -> Void in
                let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let deletePost = UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) -> Void in
                    DataService.ds.REF_POSTS.child(self.post.postKey).removeValue()
                    self.removeFromFollowersWall(key: self.post.postKey)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
                })
                let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                }
                alert.addAction(deletePost)
                alert.addAction(cancel)
                self.delegate?.present(alert, animated: true, completion: nil)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            })
            alertController.addAction(edit)
            alertController.addAction(delete)
            alertController.addAction(cancel)
            delegate?.present(alertController, animated: true, completion: nil)
        }
    }
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var isCurrentUser: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.saveBtn.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
    }
    func configureCell(_ post: Post, completionHandler:@escaping (Bool) -> Void) {
        self.post = post
        DispatchQueue.global().async {
            let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
            if currentUser == self.post.userKey {
                self.isCurrentUser = true
            } else {
                self.isCurrentUser = false
            }
        }
        DispatchQueue.main.async {
            self.likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
            self.caption.text = post.caption
            self.usernameBtn.setTitle(post.username, for: .normal)
            self.likes.text = String(post.likes)
            //download feed Img
            if let imgURL = URL(string: post.imageURL) {
                self.feedImageView.kf.setImage(with: imgURL)
            } else {
                let ref = FIRStorage.storage().reference(forURL: post.imageURL)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to Download image from Firebase storage.")
                    } else {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.feedImageView.image = img
                            }
                        }
                    }
                })
            }
            self.likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likesImg.image = UIImage(named: "empty-heart")
                    self.likesImgSm.image = UIImage(named: "empty-heart")
                } else {
                    self.likesImg.image = UIImage(named: "filled-heart")
                    self.likesImgSm.image = UIImage(named: "filled-heart")
                }
            })
        }
        completionHandler(true)
    }
    func likeTapped(_ sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.likesImgSm.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(true)
                self.likesRef.setValue(true)
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.likesImgSm.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(false)
                self.likesRef.removeValue()
            }
        })
    }
    func removeFromFollowersWall(key: String) {
        DataService.ds.REF_CURRENT_USER.child("followers").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dictionary = snap.value as? [String: Any] {
                        let followers = dictionary["user"] as! String
                        DataService.ds.REF_USERS.child(followers).child("wall").queryOrderedByKey().queryEqual(toValue: key).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let _ = snapshot.value as? NSNull {
                            } else {
                                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                    for snap in snapshot {
                                        DataService.ds.REF_USERS.child(followers).child("wall").child(snap.key).removeValue()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
    }
}
