//
//  ProfileVC2.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/7/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC2: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var parentsNameField: UITextField!
    
    @IBAction func nextBtnTapped(_ sender: AnyObject) {
        let userInfo: Dictionary<String, Any> = [
            "username": usernameField.text! as String,
            "full-name": fullNameField.text! as String,
            "parents-name": parentsNameField.text! as String
        ]
        
        let firebasePost = DataService.ds.REF_CURRENT_USER
        firebasePost.updateChildValues(userInfo)
        
        performSegue(withIdentifier: "toProfileVC3", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
