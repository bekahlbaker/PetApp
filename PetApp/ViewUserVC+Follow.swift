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
        DataService.ds.REF_CURRENT_USER.child("following").child(ViewUserVC.usernamePassed).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.isFollowing = false
            } else {
                self.isFollowing = true
            }
        })
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
        print("Follow btn tapped")
        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["\(ViewUserVC.usernamePassed)": true])
        self.user.adjustFollowing(true)
        DataService.ds.REF_USERS.child(ViewUserVC.usernamePassed).child("followers").updateChildValues(["\(KeychainWrapper.standard.string(forKey: KEY_UID)! as String)": true])
        self.user.adjustFollowers(userKey: ViewUserVC.usernamePassed, true)
        self.isFollowing = true
    }
    func unfollow() {
        print("Unfollow btn tapped")
        DataService.ds.REF_CURRENT_USER.child("following").child(ViewUserVC.usernamePassed).removeValue()
        self.user.adjustFollowing(false)
        DataService.ds.REF_USERS.child(ViewUserVC.usernamePassed).child("followers").child(KeychainWrapper.standard.string(forKey: KEY_UID)! as String).removeValue()
        self.user.adjustFollowers(userKey: ViewUserVC.usernamePassed, false)
        self.isFollowing = false
    }
}
