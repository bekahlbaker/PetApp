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

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var userList = [String]()

override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
}
    
override func viewDidAppear(_ animated: Bool) {
    getUserList()
}

func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.userList.count
    
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")! 
    cell.textLabel?.text = userList[indexPath.row]
    return cell
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

}
