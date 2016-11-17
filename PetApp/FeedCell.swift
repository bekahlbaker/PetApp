//
//  FeedCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/12/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var caption: UITextView!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    func configureCell(post: Post) {
        self.post = post
        
        self.caption.text = post.caption
        self.username.text = post.username
    }

}
