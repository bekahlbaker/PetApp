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
    func loadUserInfo() {
        DispatchQueue.global().async {
            let userKey = ViewUserVC.usernamePassed
            DataService.ds.REF_USERS.child(userKey!).child("user-info").observe(.value, with: { (snapshot) in
                if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                    print(userDict)
                    let user = User(userKey: userKey!, userData: userDict)
                    self.user = user
                }
                if self.user != nil {
                    print("Not nil")
                    self.configureUser(self.user)
                } else {
                    print("No user info")
                }
            })
        }
        
    }
    
    func configureUser(_ user: User) {
        self.user = user
        
        self.username.title = user.username
        self.fullNameLbl.text = user.name
        self.parentsNameLbl.text = user.parentsName
        self.locationLbl.text = user.location
        self.bioLbl.text = user.about
        //        self.followersLabel.text = String(user.followers)
        //        self.followingLabel.text = String(user.following)
        
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
    }
    
    
    func downloadViewUserContent() {
        checkIfFollowing()
        loadUserInfo()
        downloadCollectionViewData()
    }
    
    
    func moreTapped() {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "ProfileVC", sender: nil)
        })
        let logOut = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
            let confirmLogOut = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                try! FIRAuth.auth()?.signOut()
                self.performSegue(withIdentifier: "EntryVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            alert.addAction(confirmLogOut)
            alert.addAction(cancel)
            
            self.navigationController?.present(alert, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        alertController.addAction(edit)
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
}
