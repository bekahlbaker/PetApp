//
//  FeedCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/12/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//
//  swiftlint:disable force_cast

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper
import Crashlytics

class FeedCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var viewCommentsBtn: UIButton!
    @IBOutlet weak var goView: UIView!
    @IBOutlet weak var goViewImage: UIImageView!
    weak var delegate: UIViewController?
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
    static var isConfigured: Bool!
    var isCurrentUser: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.cellContentView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.cellContentView.addGestureRecognizer(swipeRight)
        self.commentTextFieldView.layer.borderColor = UIColor.lightGray.cgColor
        self.commentTextFieldView.layer.borderWidth = 0.5
        self.commentTextField.delegate = self
        DataService.ds.REF_CURRENT_USER.child("user-info").observe( .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.currentUsername = currentUser as String!
                }
            }
        })
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                let right = CGAffineTransform(translationX: 0, y: 0)
                UIView.animate(withDuration: 1, delay: 0.0, options: [], animations: {
                    self.cellContentView.transform = right
                    self.goViewImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                }, completion: nil)
            case UISwipeGestureRecognizerDirection.left:
                let left = CGAffineTransform(translationX: -self.cellContentView.frame.width + 22, y: 0)
                UIView.animate(withDuration: 1, delay: 0.0, options: [], animations: {
                    self.cellContentView.transform = left
                    self.goViewImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }, completion: nil)
            default:
                break
            }
        }
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
            self.downloadComments()
            self.activitySpinner.startAnimating()
            self.likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
            self.caption.text = post.caption
            self.usernameBtn.setTitle(post.username, for: .normal)
            self.likes.text = String(post.likes)
            let right = CGAffineTransform(translationX: 0, y: 0)
            UIView.animate(withDuration: 0, delay: 0.0, options: [], animations: {
                self.cellContentView.transform = right
                self.goViewImage.image = UIImage(named: "GO-left")
            }, completion: nil)
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
            self.likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likesImg.image = UIImage(named: "paw-print")
                } else {
                    self.likesImg.image = UIImage(named: "like-paw-print")
                }
            })
        }
    }
    func likeTapped(_ sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "paw-print")
                self.post.adjustLikes(true)
                self.likesRef.setValue(true)
                self.likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let _ = snapshot.value as? NSNull {
                        self.likesImg.image = UIImage(named: "paw-print")
                    } else {
                        self.likesImg.image = UIImage(named: "like-paw-print")
                    }
                })
                self.likes.text = String(self.post.likes)
            } else {
                self.likesImg.image = UIImage(named: "like-paw-print")
                self.post.adjustLikes(false)
                self.likesRef.removeValue()
                self.likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let _ = snapshot.value as? NSNull {
                        self.likesImg.image = UIImage(named: "paw-print")
                    } else {
                        self.likesImg.image = UIImage(named: "like-paw-print")
                    }
                })
                self.likes.text = String(self.post.likes)
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
    var comments = [Comment]()
    @IBOutlet weak var cmtUsernameLbl1: UILabel!
    @IBOutlet weak var cmtLbl1: UILabel!
    @IBOutlet weak var cmtUsernameLbl2: UILabel!
    @IBOutlet weak var cmtLbl2: UILabel!
    @IBOutlet weak var cmtUsernameLbl3: UILabel!
    @IBOutlet weak var cmtLbl3: UILabel!
    @IBOutlet weak var cmtUsernameLbl4: UILabel!
    @IBOutlet weak var cmtLbl4: UILabel!
    @IBOutlet weak var sendCommentBtn: UIButton!
    var currentUsername: String!
    @IBAction func sendCommentBtnTapped(_ sender: Any) {
        let comment: [String: Any] = [
            "comment": self.commentTextField.text! as String,
            "username": self.currentUsername as String,
            "userKey": KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        ]
        let firebasePost = DataService.ds.REF_POSTS.child(self.post.postKey)
        firebasePost.child("comments").childByAutoId().setValue(comment)
        self.commentTextField.text = ""
    }
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentTextFieldView: UIView!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
