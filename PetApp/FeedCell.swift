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
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likes: UILabel!
    
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        
    }
    
    
    func configureCell(post: Post, img: UIImage? = nil) {
        
        self.post = post
        
        likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKeys)
        
        self.caption.text = post.caption
        self.username.text = post.username
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
        
        //download profile img
        DataService.ds.REF_USERS.queryOrdered(byChild: "username").queryEqual(toValue: post.username).observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                
            if let dictionary = snap.value as? [String: Any] {
                    
                let profileImgUrl = dictionary["profileImgUrl"] as? String
                let storage = FIRStorage.storage()
                if profileImgUrl != nil {
                    let storageRef = storage.reference(forURL: profileImgUrl!)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("Unable to download image from firebase")
                        } else {
                            //use Kingfisher
                            if let imageUrl = URL(string: profileImgUrl!) {
                                self.profileImg.kf.indicatorType = .activity
                                self.profileImg.kf.setImage(with: imageUrl)
                                print("Using kingfisher image for profile.")
                            }else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                                print("Using firebase image for profile")
                            }
                            
                        }
                    }

                } else {
                    print("No profile image")
                }
            }
        }
    }
    })
        
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
    
}
