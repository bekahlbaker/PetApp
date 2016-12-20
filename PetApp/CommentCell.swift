//
//  CommentCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var username: UILabel!
    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configureCell(post: Post) {
       self.post = post
        
//        self.comment.text = post.comment
        self.username.text = post.username
    }

}
