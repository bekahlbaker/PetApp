// thanks to www.appcoda.com/custom-search-bar-tutorial/
//
//  UserListVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController: UISearchController!
    @IBOutlet weak var tableView: UITableView!
    
    var userList = [String]()
    var filteredUserList = [String]()
    var inSearchMode = false
    var usernameToPass: String!

override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    configureSearchController()
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    navigationItem.title = "Users"
    
}
    
override func viewDidAppear(_ animated: Bool) {
    getUserList()
}

func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if inSearchMode {
        return filteredUserList.count
    }
    return self.userList.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")!
    if inSearchMode {
        cell.textLabel?.text = filteredUserList[indexPath.row]
    } else {
     cell.textLabel?.text = userList[indexPath.row]
    }
    return cell
}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)! as UITableViewCell
        let username = (currentCell.textLabel?.text)!
        self.getUserKey(username: username)
    }
    
    func getUserKey(username: String) {
        DataService.ds.REF_USERS.queryOrdered(byChild: "user-info/username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("USER KEY \(snap.key)")
                    ViewUserVC.usernamePassed = snap.key
                    print(ViewUserVC.usernamePassed)
                    print("Happens after user key")
                    self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                }
            }
        })
    }
    
    func getUserList() {
        DataService.ds.REF_USER_LIST.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.userList = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dictionary = snap.value as? [String: Any] {
                        let user = dictionary["username"] as! String
                        self.userList.append(user)
                    } else {
                        print("No users")
                    }
                }
            }
            if self.userList.count > 0 {
                self.tableView.reloadData()
            }
        })
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
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ViewUserVC" {
//            ViewUserVC.usernamePassed = self.usernameToPass
//        }
//    }
}
