//
//  ViewUserVC+UserInfo.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/19/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

extension ViewUserVC {
    func downloadUserInof() {
        //download user info & image
        let userKey = ViewUserVC.usernamePassed
        DataService.ds.REF_USERS.child(userKey!).child("user-info").observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let username = dictionary["username"] as? String {
                    self.username.title = username
                }
                if let name = dictionary["full-name"] as? String {
                    self.fullNameLbl.text = name
                }
                if let breed = dictionary["breed"] as? String {
                    if let age = dictionary["age"] as? String {
                        if age != "" {
                            self.ageAndBreedLbl.text = "\(age)"
                            if breed != "" {
                                self.ageAndBreedLbl.text = "\(age) \(breed)"
                            } else {
                                if let species = dictionary["species"] as? String {
                                    if species != "" {
                                        self.ageAndBreedLbl.text = "\(age) \(species)"
                                    }
                                }
                            }
                        } else {
                            if breed != "" {
                                self.ageAndBreedLbl.text = "\(breed)"
                            } else {
                                if let species = dictionary["species"] as? String {
                                    if species != "" {
                                        self.ageAndBreedLbl.text = "\(species)"
                                    }
                                }
                            }
                        }
                    }
                }
                if let parent = dictionary["parents-name"] as? String {
                    if parent != "" {
                        self.parentsNameLbl.text = "Parent: \(parent)"
                    }
                }
                if let location = dictionary["location"] as? String {
                    self.locationLbl.text = location
                }
                if let about = dictionary["about"] as? String {
                    self.bioLbl.text = about
                }
                if let following = dictionary["followingCt"] as? Int {
                    self.followingLbl.text = "\(following)"
                }
                //download profile img
                if let url = dictionary["profileImgUrl"] as? String {
                    let storage = FIRStorage.storage()
                    let storageRef = storage.reference(forURL: url)
                    storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("Unable to download image from firebase")
                        } else {
                            let profileImg = UIImage(data: data!)
                            self.profileImg.image = profileImg
                        }
                    }
                }
                //download cover photo
                if let url = dictionary["coverImgUrl"] as? String {
                    let storage = FIRStorage.storage()
                    let storageRef = storage.reference(forURL: url)
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
        })
    }
}
