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
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    func configureCell(post: Post) {
        self.post = post
        
        self.caption.text = post.caption
        self.username.text = post.username
            
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
                
            if let dictionary = snapshot.value as? [String: Any] {
                    
                let profileImgUrl = dictionary["profileImgUrl"] as? String

                //download profile img
                let storage = FIRStorage.storage()
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
        }
    })
}

    @IBOutlet weak var likesBtnTapped: UIImageView!
}
