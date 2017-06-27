//
//  UsernameListCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 6/27/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class UsernameListCell: UITableViewCell {
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var followingImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    var userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
    @IBAction func followBtnTapped(_ sender: Any) {
        if isFollowing == true {
            DataService.ds.REF_CURRENT_USER.child("following").child(user.userKey).removeValue()
        } else {
            DataService.ds.REF_CURRENT_USER.child("following").updateChildValues([user.userKey: true])
        }
    }
    var user: User!
    var isFollowing: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(user: User) {
        self.user = user
        self.usernameLbl.text = user.username
        DataService.ds.REF_CURRENT_USER.child("following").child(user.userKey).observe(.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.isFollowing = false
                self.followingImg.image = UIImage(named: "add")
            } else {
                self.isFollowing = true
                self.followingImg.image = UIImage(named: "following")
            }
        })
    }
}
