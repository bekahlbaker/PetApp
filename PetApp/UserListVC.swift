// thanks to www.appcoda.com/custom-search-bar-tutorial/
//
//  UserListVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
// swiftlint:disable force_cast

import UIKit
import Foundation
import Firebase
import SwiftKeychainWrapper
import Crashlytics

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    var searchController: UISearchController!
    @IBOutlet weak var tableView: UITableView!
    var userKeys = [String]()
    var userList = [User]()
    var filteredUserList = [User]()
    var usernames = [String]()
    var filteredUsernames = [String]()
    var inSearchMode = false
    var userKeyToPass: String!
    var currentUsername: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        configureSearchController()
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "Users"
    }
    override func viewDidAppear(_ animated: Bool) {
        getUserList {(success) in
            if success {
                self.tableView.reloadData()
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if inSearchMode {
//            return filteredUserList.count
//        }
        return self.userList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if inSearchMode {
//            let user = self.filteredUserList[indexPath.row]
//            if  let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameListCell") as? UsernameListCell {
//                cell.delegate = self
//                cell.configureCell(user: user)
//                DataService.ds.REF_USERS.child(user.userKey).child("user-info").observe( .value, with: { (snapshot) in
//                    if let dictionary = snapshot.value as? [String: Any] {
//                        if let profileURL = dictionary["profileImgUrl"] as? String {
//                            let ref = FIRStorage.storage().reference(forURL: profileURL)
//                            ref.data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
//                                if error != nil {
//                                    print("Unable to Download profile image from Firebase storage.")
//                                } else {
//                                    if let imgData = data {
//                                        if let profileImg = UIImage(data: imgData) {
//                                            cell.profileImg.image = profileImg
//                                        }
//                                    }
//                                }
//                            })
//                        }
//                    }
//                })
//                return cell
//            } else {
//                return UsernameListCell()
//            }
//        } else {
            let user = self.userList[indexPath.row]
            if  let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameListCell") as? UsernameListCell {
                cell.delegate = self
                cell.configureCell(user: user)
                DataService.ds.REF_USERS.child(user.userKey).child("user-info").observe( .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        if let profileURL = dictionary["profileImgUrl"] as? String {
                            let ref = FIRStorage.storage().reference(forURL: profileURL)
                            ref.data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                                if error != nil {
                                    print("Unable to Download profile image from Firebase storage. \(String(describing: error))")
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
//        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if inSearchMode {
//            let user = self.filteredUserList[indexPath.row]
//            self.userKeyToPass = user.userKey
//            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
//        } else {
            let user = self.userList[indexPath.row]
            self.userKeyToPass = user.userKey
            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            let myVC = segue.destination as! ViewUserVC
            myVC.userKeyPassed = self.userKeyToPass
        }
    }
}
