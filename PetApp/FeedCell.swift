//
//  FeedCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/12/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper


class FeedCell: UITableViewCell {
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var profileActivitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likesImgSm: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var viewCommentsBtn: UIButton!
    @IBOutlet weak var captionEditTextView: UITextView!
    
    var delegate: UIViewController?
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBAction func moreBtnTapped(_ sender: Any) {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            self.moreBtn.isEnabled = false
            self.caption.isHidden = true
            self.captionEditTextView.isHidden = false
            self.saveBtn.isHidden = false
            self.captionEditTextView.text = self.caption.text
            self.captionEditTextView.becomeFirstResponder()
        })
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Delete Post", style: .destructive, handler: { (action) -> Void in
                DataService.ds.REF_POSTS.child(self.post.postKey).removeValue()
                self.removeFromFollowersWall(key: self.post.postKey)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            
            alert.addAction(deletePost)
            alert.addAction(cancel)
            
            self.delegate?.present(alert, animated: true, completion: nil)
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        delegate?.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.moreBtn.isEnabled = true
        self.caption.isHidden = false
        self.captionEditTextView.isHidden = true
        self.saveBtn.isHidden = true
        self.caption.text = self.captionEditTextView.text
        DataService.ds.REF_POSTS.child(self.post.postKey).updateChildValues(["caption": "\(caption.text!)"])
    }
    @IBAction func usernameTapped(_ sender: AnyObject) {
        tapActionUsername?(self)
    }
    var tapActionUsername: ((UITableViewCell) -> Void)?
    
    @IBAction func viewCommentsTapped(_ sender: Any) {
        tapActionComments?(self)
    }
    var tapActionComments: ((UITableViewCell) -> Void)?
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    static var isConfigured: Bool!
    var isCurrentUser: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.saveBtn.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustCommentCountTrue(notification:)), name:NSNotification.Name(rawValue: "adjustCommentCountTrue"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustCommentCountFalse(notification:)), name:NSNotification.Name(rawValue: "adjustCommentCountFalse"), object: nil)
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
            self.activitySpinner.startAnimating()
            self.profileActivitySpinner.startAnimating()
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
                                self.activitySpinner.stopAnimating()
                            }
                        }
                    }
                    
                })
            }
            self.likesRef.observeSingleEvent(of: .value, with:  { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likesImg.image = UIImage(named: "empty-heart")
                    self.likesImgSm.image = UIImage(named: "empty-heart")
                } else {
                    self.likesImg.image = UIImage(named: "filled-heart")
                    self.likesImgSm.image = UIImage(named: "filled-heart")
                }
            })
            FeedCell.isConfigured = true
        }
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.likesImgSm.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(true)
                self.likesRef.setValue(true)
                self.configureCell(self.post)
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.likesImgSm.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(false)
                self.likesRef.removeValue()
                self.configureCell(self.post)
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
    
    func adjustCommentCountTrue(notification: NSNotification) {

            DataService.ds.REF_POSTS.child(post.postKey).child("commentCount").observeSingleEvent(of: .value, with: { (snapshot) in

                self.post.adjustCommentCount(true)

//                if let _ = snapshot.value as? NSNull {
//                    print("No comments")
//                } else {
//                    if let count = snapshot.value as? Int {
//                        print(count)
//                    }
//                }
            })

    }
    
    func adjustCommentCountFalse(notification: NSNotification) {
        
        DataService.ds.REF_POSTS.child(post.postKey).child("commentCount").observeSingleEvent(of: .value, with: { (snapshot) in

                self.post.adjustCommentCount(false)

            //                if let _ = snapshot.value as? NSNull {
            //                    print("No comments")
            //                } else {
            //                    if let count = snapshot.value as? Int {
            //                        print(count)
            //                    }
            //                }
        })
        
    }
}
