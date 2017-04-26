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
        DispatchQueue.global().async {
                if self.userKeyPassed != nil {
                    print("NOT CURRENT USER")
                    self.isCurrentUser = false
                    DataService.ds.REF_USERS.child(self.userKeyPassed).child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userDict = snapshot.value as? [String: AnyObject] {
                            let user = User(userKey: self.userKeyPassed, userData: userDict)
                            self.user = user
                        }
                        if self.user != nil {
                            self.configureUser(self.user)
                        } else {
                            print("No user info")
                        }
                    })
                } else {
                    print("CURRENT USER")
                    self.isCurrentUser = true
                    DataService.ds.REF_USERS.child(self.userKey).child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userDict = snapshot.value as? [String: AnyObject] {
                            let user = User(userKey: self.userKey, userData: userDict)
                            self.user = user
                        }
                        if self.user != nil {
                            self.configureUser(self.user)
                        } else {
                            print("No user info")
                        }
                    })
                }
        }
    }
    func configureUser(_ user: User) {
        self.user = user
        self.username.title = user.username
        self.fullNameLbl.text = user.name
        self.parentsNameLbl.text = user.parentsName
        self.locationLbl.text = user.location
        self.bioLbl.text = user.about
        self.followersLbl.text = String(user.followers)
        self.followingLbl.text = String(user.following)
        if user.age != "" {
            self.ageAndBreedLbl.text = user.age
            if user.breed != "" {
                self.ageAndBreedLbl.text = user.age + " " + user.breed
            } else {
                if user.species != "" {
                    self.ageAndBreedLbl.text = user.age + " " + user.species
                }
            }
        } else {
            if user.breed != "" {
                self.ageAndBreedLbl.text = user.breed
            } else {
                if user.species != "" {
                    self.ageAndBreedLbl.text = user.species
                }
            }
        }
        self.profileImg.image = UIImage(named: "user-sm")
        DataService.ds.REF_CURRENT_USER.child("user-info").observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                //download profile img
                if ProfileVC.profileCache.object(forKey: "profileImg") != nil {
                    self.profileImg.image = ProfileVC.profileCache.object(forKey: "profileImg")
                    print("Using cached img")
                } else {
                    guard let profileUrl = dictionary["profileImgUrl"] as? String else {
                        return
                    }
                    if profileUrl == (dictionary["profileImgUrl"] as? String)! {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: profileUrl)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                            }
                        }
                    }
                }
                //download cover photo
                if ProfileVC.coverCache.object(forKey: "coverImg") != nil {
                    self.coverImg.image = ProfileVC.coverCache.object(forKey: "coverImg")
                } else {
                    guard let coverUrl = dictionary["coverImgUrl"] as? String else {
                        return
                    }
                    if coverUrl == (dictionary["coverImgUrl"] as? String)! {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: coverUrl)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let coverImg = UIImage(data: data!)
                                self.coverImg.image = coverImg
                            }
                        }
                    }
                }
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
                ProfileVC.profileCache.removeAllObjects()
                FeedVC.imageCache.removeAllObjects()
                ProfileVC.coverCache.removeAllObjects()
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
