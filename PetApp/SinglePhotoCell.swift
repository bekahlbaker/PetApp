//
//  SinglePhotoCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/13/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

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
    @IBOutlet weak var captionEditTextView: UITextView!
    @IBOutlet weak var viewCommentsBtn: UIButton!
    weak var delegate: UIViewController?
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.moreBtn.isEnabled = true
        self.caption.isHidden = false
        self.captionEditTextView.isHidden = true
        self.saveBtn.isHidden = true
        self.caption.text = self.captionEditTextView.text
        DataService.ds.REF_POSTS.child(self.post.postKey).updateChildValues(["caption": "\(caption.text!)"])
    }
    @IBOutlet weak var moreBtn: UIButton!
    @IBAction func moreBtnTapped(_ sender: Any) {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (_) -> Void in
            print("Edit btn tapped")
            self.moreBtn.isEnabled = false
            self.caption.isHidden = true
            self.captionEditTextView.isHidden = false
            self.saveBtn.isHidden = false
            self.captionEditTextView.text = self.caption.text
            self.captionEditTextView.becomeFirstResponder()
        })
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) -> Void in
            print("Delete btn tapped")
            let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) -> Void in
                print("Delete presssed")
                DataService.ds.REF_POSTS.child(self.post.postKey).removeValue()
                print("Post removed")
                _ = self.delegate?.navigationController?.popViewController(animated: true)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                print("Cancel Button Pressed")
            }
            alert.addAction(deletePost)
            alert.addAction(cancel)
            self.delegate?.present(alert, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
                print("Cancel btn tapped")
        })
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        delegate?.present(alertController, animated: true, completion: nil)
    }
    @IBAction func usernameTapped(_ sender: AnyObject) {
        tapActionUsername?(self)
    }
    @IBAction func commentTapped(_ sender: AnyObject) {
        tapActionComment?(self)
    }
    var tapActionUsername: ((UITableViewCell) -> Void)?
    var tapActionComment: ((UITableViewCell) -> Void)?
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var isCurrentUser: Bool!
    static var isConfigured: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.saveBtn.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
    }
    func configureCell(_ post: Post) {
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
            self.comments.text = String(post.commentCount)
            if post.commentCount > 0 {
                self.viewCommentsBtn.setTitle("View all \(post.commentCount) comments", for: .normal)
            } else {
                self.viewCommentsBtn.setTitle("Leave a comment", for: .normal)
            }
            if self.isCurrentUser == false {
                self.moreBtn.isHidden = true
            } else if self.isCurrentUser == true {
                self.moreBtn.isHidden = false
            }
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
            //download profile Img
            //            if let profileImgURL = URL(string: post.profileImgUrl) {
            //                self.profileImg.kf.setImage(with: profileImgURL)
            //            } else {
            //                let ref = FIRStorage.storage().reference(forURL: post.profileImgUrl)
            //                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            //                    if error != nil {
            //                        print("Unable to Download profile image from Firebase storage.")
            //                    } else {
            //                        if let imgData = data {
            //                            if let profileImg = UIImage(data: imgData) {
            //                                self.profileImg.image = profileImg
            //                            }
            //                        }
            //                    }
            //                })
            //            }
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
        SinglePhotoCell.isConfigured = true
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
}
