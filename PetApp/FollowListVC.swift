//
//  FollowListVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 4/25/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FollowListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var userKeyPassed: String!
    var userKeyToPass: String!
    var btnTagPassed: Int!
    var isCurrentUser: Bool!
    var followList = [String]()
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if userKeyPassed == KeychainWrapper.standard.string(forKey: KEY_UID) {
            self.isCurrentUser = true
            } else {
            self.isCurrentUser = false
            }
        getFollowList { (successDownloadingData) in
            if successDownloadingData {
                self.tableView.reloadData()
                print("Reload Table")
            } else {
                print("Unable to download data, try again")
            }
        }

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.users[indexPath.row]
        if  let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameListCell") as? UsernameListCell {
            cell.delegate = self
            cell.configureCell(user: user)
            DataService.ds.REF_USERS.child(user.userKey).child("user-info").observe( .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    if let profileURL = dictionary["profileImgUrl"] as? String {
                        let ref = FIRStorage.storage().reference(forURL: profileURL)
                        ref.data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                print("Unable to Download profile image from Firebase storage.")
                            } else {
                                if let imgData = data {
                                    if let profileImg = UIImage(data: imgData) {
                                        cell.profileImg.image = profileImg
                                    }
                                }
                            }
                        })
                    }
                }
            })
            return cell
        } else {
            return UsernameListCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.userKeyToPass = self.followList[indexPath.row]
        performSegue(withIdentifier: "ViewUserVC", sender: nil)
    }
    func getFollowList(completionHandler:@escaping (Bool) -> Void) {
        self.followList = []
        self.users = []
        switch self.btnTagPassed {
        case 0:
            self.navigationItem.title = "Following"
            DataService.ds.REF_USERS.child(self.userKeyPassed).child("following").observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    print("No users")
                } else {
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            self.followList.append(snap.key)
                            switch self.isCurrentUser {
                            case true:
                                self.filterOutCurrentUser(user: KeychainWrapper.standard.string(forKey: KEY_UID)! as String)
                            case false:
                                self.filterOutCurrentUser(user: self.userKeyPassed)
                            default:
                                return
                            }
                        }
                    }
                }
                for i in 0..<self.followList.count {
                    DataService.ds.REF_USERS.child(self.followList[i]).child("user-personal").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let user = User(userKey: self.followList[i], userData: dictionary)
                            self.users.append(user)
                                if self.users.count > 0 {
                                    completionHandler(true)
                                }
                        }
                    })
                }
            })
        case 1:
            self.navigationItem.title = "Followers"
            DataService.ds.REF_USERS.child(self.userKeyPassed).child("followers").observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    print("No users")
                } else {
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            self.followList.append(snap.key)
                            switch self.isCurrentUser {
                            case true:
                                self.filterOutCurrentUser(user: KeychainWrapper.standard.string(forKey: KEY_UID)! as String)
                            case false:
                                self.filterOutCurrentUser(user: self.userKeyPassed)
                            default:
                                return
                            }
                        }
                    }
                }
                for i in 0..<self.followList.count {
                    DataService.ds.REF_USERS.child(self.followList[i]).child("user-personal").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let user = User(userKey: self.followList[i], userData: dictionary)
                            self.users.append(user)
                            if self.users.count > 0 {
                                completionHandler(true)
                            }
                        }
                    })
                }
            })
        default:
            return
        }
    }
    func filterOutCurrentUser(user: String) {
        let userToRemove = user
        while self.followList.contains(user) {
            if let itemToRemoveIndex = self.followList.index(of: userToRemove) {
                self.followList.remove(at: itemToRemoveIndex)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            if let myVC = segue.destination as? ViewUserVC {
                myVC.userKeyPassed = self.userKeyToPass
            }
        }
    }
}
