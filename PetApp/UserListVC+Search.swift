//
//  UserListVC+Search.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/19/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Foundation
import Firebase

extension UserListVC {
    func getUserKey(username: String, completionHandler: @escaping (_ userKey: String) -> Void) {
        var string = String()
        DataService.ds.REF_USERS.queryOrdered(byChild: "user-info/username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    string = snap.key
//                    self.userKeyToPass = snap.key
//                    print(self.userKeyToPass)
                    completionHandler(string)
                }
            }
        })
    }
    func getUserList() {
        DataService.ds.REF_ACTIVE_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            self.userList = []
            if let _ = snapshot.value as? NSNull {
                print("No users")
            } else {
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        self.userList.append(snap.key)
                        self.filterOutCurrentUser(user: self.currentUsername)
                    }
                }
            }
            if self.userList.count > 0 {
                self.tableView.reloadData()
            }
        })
    }
    func getCurrentUsername() {
        DataService.ds.REF_CURRENT_USER.child("user-info").observe( .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.currentUsername = currentUser as String!
                }
            }
        })
    }
    func filterOutCurrentUser(user: String) {
        let userToRemove = user
        while self.userList.contains(user) {
            if let itemToRemoveIndex = self.userList.index(of: userToRemove) {
                self.userList.remove(at: itemToRemoveIndex)
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !inSearchMode {
            inSearchMode = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by username..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = true
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filteredUserList = userList.filter({ (user) -> Bool in
            let userText: NSString = user as NSString
            return (userText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        inSearchMode = true
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode = false
        tableView.reloadData()
    }
}
