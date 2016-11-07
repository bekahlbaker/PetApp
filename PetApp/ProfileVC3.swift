//
//  ProfileVC3.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/7/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC3: UIViewController {

    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var speciesField: UITextField!
    @IBOutlet weak var breedField: UITextField!
    
    
    @IBAction func doneBtnTapped(_ sender: AnyObject) {
        let userInfo: Dictionary<String, Any> = [
            "age": ageField.text! as String,
            "species": speciesField.text! as String,
            "breed": breedField.text! as String
        ]
        
        let firebasePost = DataService.ds.REF_CURRENT_USER
        firebasePost.updateChildValues(userInfo)
        
        performSegue(withIdentifier: "toFeedVC", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
