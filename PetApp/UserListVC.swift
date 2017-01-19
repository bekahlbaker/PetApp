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
    
    @IBAction func homeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var tableView: UITableView!
    var userList = [String]()
    var filteredUserList = [String]()
    var inSearchMode = false
    var usernameToPass: String!
    var currentUsername: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getCurrentUsername()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configureSearchController()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = "Users"
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
}
