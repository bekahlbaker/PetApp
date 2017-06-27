//
//  CommentCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class CommentCell: UITableViewCell {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
    var comment: Comment!
    weak var delegate: UIViewController?

    func configureCell(_ postKey: String, comment: Comment) {
        self.comment = comment
        self.commentLbl.text = comment.comment
        self.usernameLbl.text = comment.username
    }
}
