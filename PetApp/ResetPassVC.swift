//
//  ResetPassVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/14/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class ResetPassVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var successLbl: UILabel!
    
    @IBAction func sendEmailTapped(_ sender: AnyObject) {
        let email = emailTextField.text
        FIRAuth.auth()?.sendPasswordReset(withEmail: email!, completion: { (error) in
            if let error = error {
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    
                    switch errCode {
                    case .errorCodeInvalidEmail:
                        self.errorLbl.text = "Please enter a valid email address."
                    case .errorCodeUserNotFound:
                        self.errorLbl.text = "There is not an account for that email. Do you need to sign up?"
                        self.signUpBtn.isHidden = false
                    default:
                        print("Create User Error: \(error)")
                    }
                }
            } else {
                print("Password reset email successfully sent.")
                self.successLbl.isHidden = false
                self.signInBtn.isHidden = false
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpBtn.isHidden = true
        self.successLbl.isHidden = true
        self.signInBtn.isHidden = true
    }
}

