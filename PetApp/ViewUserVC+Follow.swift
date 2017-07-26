//
//  ViewUserVC+Follow.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/19/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper

extension ViewUserVC {
    func checkIfFollowing() {
        if let userKey = self.userKeyPassed {
            DataService.ds.REF_CURRENT_USER.child("following").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.isFollowing = false
                } else {
                    self.isFollowing = true
                }
            })
        }
    }
    func followTapped() {
            let alert = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
            if isFollowing == false {
                let follow = UIAlertAction(title: "Follow", style: .default, handler: { (_) -> Void in
                    self.follow()
                })
                alert.addAction(follow)
            } else if isFollowing == true {
                let follow = UIAlertAction(title: "Unfollow", style: .destructive, handler: { (_) -> Void in
                    self.unfollow()
                })
                alert.addAction(follow)
            }
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            }
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
    }
    func follow() {
        if KeychainWrapper.standard.string(forKey: KEY_UID)! as String != "v2PvUj0ddqVe0kJRoeIWtVZR9dj1" {
            if let userKey = self.userKeyPassed {
                DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["\(userKey)": true])
                DataService.ds.REF_USERS.child(userKey).child("followers").updateChildValues(["\(KeychainWrapper.standard.string(forKey: KEY_UID)! as String)": true])
                self.isFollowing = true
            }
        } else {
            let alert = UIAlertController(title: "You cannot follow or unfollow accounts while viewing as a guest.", message: "Please log out and create your own account.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    func unfollow() {
        if KeychainWrapper.standard.string(forKey: KEY_UID)! as String != "v2PvUj0ddqVe0kJRoeIWtVZR9dj1" {
            if let userKey = self.userKeyPassed {
                DataService.ds.REF_CURRENT_USER.child("following").child(userKey).removeValue()
                DataService.ds.REF_USERS.child(userKey).child("followers").child(KeychainWrapper.standard.string(forKey: KEY_UID)! as String).removeValue()
                self.isFollowing = false
            }
        } else {
            let alert = UIAlertController(title: "You cannot follow or unfollow accounts while viewing as a guest.", message: "Please log out and create your own account.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
}
