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
            let follow = UIAlertAction(title: "Follow", style: .default, handler: { (action) -> Void in
                print("Follow btn tapped")
                DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["\(ViewUserVC.usernamePassed!)": true])
                self.adjustFollowing(true)
                self.checkIfFollowing()
                DataService.ds.REF_USERS.child("\(ViewUserVC.usernamePassed!)").child("followers").updateChildValues(["\(self.userKey)": true])
                //            self.adjustFollowers(true)
                
            })
            alert.addAction(follow)
        } else if isFollowing == true {
            let follow = UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) -> Void in
                print("Unfollow btn tapped")
                DataService.ds.REF_CURRENT_USER.child("following").removeValue()
                self.adjustFollowing(false)
                self.checkIfFollowing()
                DataService.ds.REF_USERS.child("\(ViewUserVC.usernamePassed!)").child("followers").removeValue()
                //            self.adjustFollowers(true)
                
            })
            alert.addAction(follow)
        }
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func adjustFollowing(_ addFollowing: Bool) {
        DataService.ds.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                var following = dictionary["followingCt"] as? Int
                print(following!)
                if addFollowing {
                    following = following! + 1
                } else {
                    following = following! - 1
                }
                DataService.ds.REF_CURRENT_USER.updateChildValues(["followingCt": following as Any])
            }
        })
    }
}
