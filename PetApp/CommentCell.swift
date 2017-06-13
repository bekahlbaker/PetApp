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

    override func awakeFromNib() {
        super.awakeFromNib()
        //self.deleteBtn.isHidden = true
    }
    func configureCell(_ postKey: String, comment: Comment) {
        self.comment = comment
        self.commentLbl.text = comment.comment
        self.usernameLbl.text = comment.username
        if comment.userKey == self.userKey {
            self.deleteBtn.isHidden = false
        }
    }
    @IBOutlet weak var deleteBtn: UIButton!
    @IBAction func deleteBtnTapped(_ sender: Any) {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) -> Void in
            let alert = UIAlertController(title: "Are you sure you want to delete this comment?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Delete Comment", style: .destructive, handler: { (_) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteComment"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshCommentTableView"), object: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            }
            alert.addAction(deletePost)
            alert.addAction(cancel)
            self.delegate?.present(alert, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
        })
        alertController.addAction(delete)
        alertController.addAction(cancel)
        delegate?.present(alertController, animated: true, completion: nil)
    }
}
