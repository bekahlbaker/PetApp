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

class FeedCell: UITableViewCell {

    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    
    @IBAction func usernameTapped(_ sender: AnyObject) {
        getUsernameToPass()

    }
    
    @IBAction func imageTapped(_ sender: AnyObject) {
        getPostKeyToPass()
    }

    static var usernameToPass: String!
    static var postKeyToPass: String!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        
    }
    
    
    func configureCell(post: Post, img: UIImage? = nil, profileImg: UIImage? = nil) {
        
        self.post = post
        likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
        print("POST KEY: \(post.postKey)")
        
        self.caption.text = post.caption
        
        self.usernameBtn.setTitle(post.username, for: .normal)
        
        self.likes.text = String(post.likes)
        
        if img != nil {
            self.feedImageView.image = img
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
                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString)
                        }
                    }
                }
                
            })
            
        }
        
        if profileImg != nil {
            self.profileImg.image = profileImg
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
                            FeedVC.imageCache.setObject(profileImg, forKey: post.profileImgUrl as NSString)
                        }
                    }
                }
                
            })
            
        }
        
        likesRef.observeSingleEvent(of: .value, with:  { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
            }
        })

}

    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    func getUsernameToPass() {
        FeedCell.usernameToPass = ""
        FeedCell.usernameToPass = usernameBtn.titleLabel?.text
    }
    
    func getPostKeyToPass() {
        FeedCell.postKeyToPass = ""
        FeedCell.postKeyToPass = post.postKey
    }
}
