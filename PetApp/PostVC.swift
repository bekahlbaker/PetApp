//
//  PostVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class PostVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            let currentUser = snapshot.value.object(value(forKey: <#T##String#>)"username") as! String
            
            print("Username: \(currentUser)")
            self.currentUsername = currentUser
        })
    }

}
