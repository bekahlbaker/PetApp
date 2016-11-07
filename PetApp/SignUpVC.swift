//
//  SignUpVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func logInPressed(_ sender: RoundedCornerButton) {
        if let username = usernameField.text, let email = emailField.text, let password = passwordField.text {

                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase using email - \(error)")
                        } else {
                            print("Successfully authenticated with Firebase using email")
                            self.performSegue(withIdentifier: "toProfileVC", sender: nil)
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                DataService.ds.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
        }

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

}
