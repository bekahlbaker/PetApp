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
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likesImgSm: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func saveBtnTapped(_ sender: Any) {
        tapActionSave?(self)
    }
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBAction func moreBtnTapped(_ sender: Any) {
        tapActionMore?(self)
    }
    
    @IBAction func usernameTapped(_ sender: AnyObject) {
        tapActionUsername?(self)
    }
    
    @IBAction func commentTapped(_ sender: AnyObject) {
        tapActionComment?(self)
    }

    var tapActionUsername: ((UITableViewCell) -> Void)?
    var tapActionComment: ((UITableViewCell) -> Void)?
    var tapActionMore: ((UITableViewCell) -> Void)?
    var tapActionSave: ((UITableViewCell) -> Void)?
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
    
    func configureCell(post: Post) {
        
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
            
            if self.isCurrentUser == false {
                self.moreBtn.isHidden = true
            } else if self.isCurrentUser == true {
                self.moreBtn.isHidden = false
            }
            
            if let imgURL = URL(string: post.imageURL) {
                self.feedImageView.kf.setImage(with: imgURL)
                print("using kingfisher for feed image")
            } else {
                let ref = FIRStorage.storage().reference(forURL: post.imageURL)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to Download image from Firebase storage.")
                    } else {
                        print("Image downloaded from FB Storage.")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.feedImageView.image = img
                            }
                        }
                    }
                    
                })
                
            }
            
            if let profileImgURL = URL(string: post.profileImgUrl) {
                self.profileImg.kf.setImage(with: profileImgURL)
                print("using kingfisher for feed image")
            } else {
                let ref = FIRStorage.storage().reference(forURL: post.profileImgUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to Download profile image from Firebase storage.")
                    } else {
                        print("Image downloaded from FB Storage.")
                        if let imgData = data {
                            if let profileImg = UIImage(data: imgData) {
                                self.profileImg.image = profileImg
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

        }
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.likesImgSm.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.likesImgSm.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
}
