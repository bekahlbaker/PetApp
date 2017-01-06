//
//  CommentCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    var comment: Comment!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configureCell(_ postKey: String, comment: Comment) {
        
        self.comment = comment
        
        self.commentLbl.text = comment.comment
        
        self.usernameLbl.text = comment.username
    }

}
