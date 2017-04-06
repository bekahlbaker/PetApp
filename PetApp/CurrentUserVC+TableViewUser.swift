//
//  CurrentUserVC+TableViewUser.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/22/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper

extension CurrentUserVC {
    func loadUserInfo(_ sender: AnyObject) {
        DispatchQueue.global().async {
            let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
            DataService.ds.REF_USERS.child(userKey).child("user-info").observe(.value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String: AnyObject] {
                    print(userDict)
                    let user = User(userKey: userKey, userData: userDict)
                    self.user = user
                }
                if self.user != nil {
                    print("Not nil")
                    self.perform(#selector(self.loadTableData(_:)), with: nil, afterDelay: 0.2)
                } else {
                    print("No user info")
                }
            })
        }
    }
    func loadTableData(_ sender: AnyObject) {
        self.tableViewUser.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let user = self.user {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell {
                cell.configureUser(user)
                return cell
            } else {
                return UserCell()
            }
        } else {
            return UserCell()
        }
    }
}
