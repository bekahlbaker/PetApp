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
import SwiftKeychainWrapper
import Crashlytics

extension UserListVC {
    func getUserList(completionHandler:@escaping (Bool) -> Void) {
        DataService.ds.REF_USERS.keepSynced(true)
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("No users")
            } else {
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    self.userList = []
                    for snap in snapshot {
                        DataService.ds.REF_USERS.child(snap.key).child("user-personal").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                let user = User(userKey: snap.key, userData: dictionary)
                                self.userList.append(user)
                                completionHandler(true)
                            }
                        })
                    }
                }
            }
        })
    }
    func filterOutCurrentUser(user: String) {
        let userToRemove = user
        while self.userKeys.contains(user) {
            if let itemToRemoveIndex = self.userKeys.index(of: userToRemove) {
                self.userKeys.remove(at: itemToRemoveIndex)
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
        if let searchString = searchController.searchBar.text {
            self.filteredUsernames = []
            self.filteredUsernames = self.usernames.filter({ (user) -> Bool in
                let userText: NSString = user as NSString
                return (userText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
            for i in 0..<self.filteredUsernames.count {
                DataService.ds.REF_USERS.child(self.userKeys[i]).child("user-personal").observe(.value, with: { (snapshot) in
                    self.filteredUserList = []
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let user = User(userKey: snapshot.key, userData: dictionary)
                        self.filteredUserList.append(user)
                        if self.filteredUserList.count > 0 {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
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
