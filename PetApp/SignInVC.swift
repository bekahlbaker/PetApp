//
//  SignInVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {

 
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticated with Firebase")
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        DataService.ds.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    print("Unable to authenticate with Firebase using email - \(error)")
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

