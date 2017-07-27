//
//  ViewUserVC+UserInfo.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/19/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
// swiftlint:disable force_try

import UIKit
import Firebase
import SwiftKeychainWrapper

extension ViewUserVC {
    func loadUserInfo() {
        if checkIfUserIsCurrentUser() {
            DataService.ds.REF_USERS.child(self.currentUserKey).child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String: AnyObject] {
                    let user = User(userKey: self.currentUserKey, userData: userDict)
                    self.user = user
                    DispatchQueue.global().async {
                        guard let profileUrl = userDict["profileImgUrl"] as? String else {
                            return
                        }
                        if profileUrl == (userDict["profileImgUrl"] as? String)! {
                            let storage = FIRStorage.storage()
                            let storageRef = storage.reference(forURL: profileUrl)
                            storageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) in
                                if error != nil {
                                    print("Unable to download image from firebase")
                                } else {
                                    let profileImg = UIImage(data: data!)
                                    DispatchQueue.main.async {
                                        self.profileImg.image = profileImg
                                    }
                                }
                            }
                        }
                    }
                }
                if self.user != nil {
                    self.configureUser(self.user, userKey: self.currentUserKey)
                } else {
                    print("No user info")
                }
            })
        } else {
            DataService.ds.REF_USERS.child(self.userKeyPassed).child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String: AnyObject] {
                    let user = User(userKey: self.userKeyPassed, userData: userDict)
                    self.user = user
                    DispatchQueue.global().async {
                        guard let profileUrl = userDict["profileImgUrl"] as? String else {
                            return
                        }
                        if profileUrl == (userDict["profileImgUrl"] as? String)! {
                            let storage = FIRStorage.storage()
                            let storageRef = storage.reference(forURL: profileUrl)
                            storageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) in
                                if error != nil {
                                    print("Unable to download image from firebase")
                                } else {
                                    let profileImg = UIImage(data: data!)
                                    DispatchQueue.main.async {
                                        self.profileImg.image = profileImg
                                    }
                                }
                            }
                        }
                    }                }
                if self.user != nil {
                    self.configureUser(self.user, userKey: self.userKeyPassed)
                } else {
                    print("No user info")
                }
            })
        }
    }
    func configureUser(_ user: User, userKey: String) {
        self.user = user
        self.navigationItem.title = user.username
        self.fullNameLbl.text = user.name
        self.parentsNameLbl.text = user.parentsName
        //        self.secondparentsNameLbl.text = user.secondParentsName
        self.locationLbl.text = user.location
        self.bioLbl.text = user.about
        if user.breed != "" {
            self.ageAndBreedLbl.text = user.breed
        } else {
            if user.species != "" {
                self.ageAndBreedLbl.text = user.species
            }
        }
        self.profileImg.image = UIImage(named: "user-sm")
        DataService.ds.REF_USERS.child(userKey).child("following").observe(.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("Not following anyone")
            } else {
                self.followingLbl.text = String(snapshot.childrenCount - 1)
            }
        })
        DataService.ds.REF_USERS.child(userKey).child("followers").observe(.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("No followers")
            } else {
                self.followersLbl.text = String(snapshot.childrenCount - 1)
            }
        })
    }
    func downloadViewUserContent() {
        checkIfFollowing()
        loadUserInfo()
        downloadCollectionViewData()
    }
    func moreTapped() {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (_) -> Void in
            self.performSegue(withIdentifier: "ProfileVC", sender: nil)
        })
        let logOut = UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) -> Void in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
            let confirmLogOut = UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) -> Void in
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                try! FIRAuth.auth()?.signOut()
//                ProfileVC.profileCache.removeAllObjects()
                FeedVC.imageCache.removeAllObjects()
                self.performSegue(withIdentifier: "EntryVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            }
            alert.addAction(confirmLogOut)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
        })
        alertController.addAction(edit)
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}
