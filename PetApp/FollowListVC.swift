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
    var btnTagPassed: Int!
    var isCurrentUser: Bool!
    var followList = [String]()
    var usernames = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print(self.isCurrentUser)
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
        return self.usernames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell")!
        cell.textLabel?.text = self.usernames[indexPath.row]
        return cell
    }
    func getFollowList(completionHandler:@escaping (Bool) -> Void) {
        switch self.btnTagPassed {
        case 0:
            print("FOLLOWING")
            DataService.ds.REF_USERS.child(self.userKeyPassed).child("following").observeSingleEvent(of: .value, with: { (snapshot) in
                self.followList = []
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
                    print(self.followList[i])
                    DataService.ds.REF_USERS.child(self.followList[i]).child("user-personal").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: Any] {
                            if let username = dictionary["username"] as? String {
                                self.usernames.append(username)
                                if self.usernames.count > 0 {
                                    completionHandler(true)
                                }
                            }
                        }
                    })
                }
            })
        case 1:
            print("FOLLOWERS")
            DataService.ds.REF_USERS.child(self.userKeyPassed).child("followers").observeSingleEvent(of: .value, with: { (snapshot) in
                self.followList = []
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
                    print(self.followList[i])
                    DataService.ds.REF_USERS.child(self.followList[i]).child("user-personal").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: Any] {
                            if let username = dictionary["username"] as? String {
                                self.usernames.append(username)
                                if self.usernames.count > 0 {
                                    completionHandler(true)
                                }
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
}
