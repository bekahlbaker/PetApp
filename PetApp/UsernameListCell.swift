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
    weak var delegate: UIViewController?
    @IBAction func followBtnTapped(_ sender: Any) {
        if KeychainWrapper.standard.string(forKey: KEY_UID)! as String != "v2PvUj0ddqVe0kJRoeIWtVZR9dj1" {
            if isFollowing == true {
                DataService.ds.REF_CURRENT_USER.child("following").child(user.userKey).removeValue()
            } else {
                DataService.ds.REF_CURRENT_USER.child("following").updateChildValues([user.userKey: true])
            }
        } else {
            let alert = UIAlertController(title: "You cannot follow or unfollow accounts while viewing as a guest.", message: "Please log out and create your own account.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            self.delegate?.present(alert, animated: true, completion: nil)
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
    func configureCellForExploreUsers(user: User) {
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
