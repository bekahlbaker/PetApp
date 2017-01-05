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
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!

    @IBOutlet weak var profileActivitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var likesImgSm: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var usernameBtn: UIButton!
    
    @IBAction func usernameTapped(_ sender: AnyObject) {
        tapActionUsername?(self)
    }
    
    @IBAction func imageTapped(sender: AnyObject) {
        tapAction?(self)
    }

    @IBAction func commentTapped(_ sender: AnyObject) {
        tapActionComment?(self)
    }
    
    var tapAction: ((UITableViewCell) -> Void)?
    var tapActionUsername: ((UITableViewCell) -> Void)?
    var tapActionComment: ((UITableViewCell) -> Void)?
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    static var isConfigured: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        
    }
    
    
    func configureCell(post: Post) {

        DispatchQueue.main.async {
            self.activitySpinner.startAnimating()
            self.profileActivitySpinner.startAnimating()
            
            self.post = post
            
            self.likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
            
            self.caption.text = post.caption
            
            self.usernameBtn.setTitle(post.username, for: .normal)
            
            self.likes.text = String(post.likes)
            
            self.comments.text = String(post.commentCount)
            
            if let imgURL = URL(string: post.imageURL) {
                self.feedImageView.kf.setImage(with: imgURL)
                print("using kingfisher for feed image")
            } else {
                let ref = FIRStorage.storage().reference(forURL: post.imageURL)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to Download image from Firebase storage.")
                    } else {
                        print("Feed image downloaded from FB Storage.")
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

        }
    FeedCell.isConfigured = true
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
