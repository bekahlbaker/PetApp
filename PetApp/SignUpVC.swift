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
    

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBAction func logInPressed(_ sender: RoundedCornerButton) {

        if passwordField.text == "" {
            self.errorLbl.text = "Please enter a valid password."
        } else if passwordField.text != password2.text {
            self.errorLbl.text = "Your passwords do not match. Please try again."
        } else if let email = emailField.text, let password = passwordField.text {
            
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            
                            if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                                
                                switch errCode {
                                case .errorCodeInvalidEmail:
                                    print("Invalid email")
                                    self.errorLbl.text = "Please enter a valid email address."
                                    self.signInBtn.isHidden = true
                                case .errorCodeEmailAlreadyInUse:
                                    self.errorLbl.text = "This email is already in use. Do you need to sign in?"
                                    self.signInBtn.isHidden = false
                                case .errorCodeWeakPassword:
                                    self.errorLbl.text = "Your password needs to be at least 6 characters. Please enter a new password."
                                    self.signInBtn.isHidden = true
                                
                                default:
                                    print("Create User Error: \(error)")
                                }
                                
                            }
                        } else {
                            print("Successfully authenticated with Firebase using email")
                            if let user = user {
                                let userData = ["provider": user.providerID, "email": email]
                                DataService.ds.completeSignIn(user.uid, userData: userData)
                                DataService.ds.REF_CURRENT_USER.child("following").childByAutoId().updateChildValues(["user": user.uid])
                                DataService.ds.REF_CURRENT_USER.child("followers").childByAutoId().updateChildValues(["user": user.uid])
                                
                                    DataService.ds.REF_CURRENT_USER.updateChildValues(["followingCt": 1])
                            }
                            self.performSegue(withIdentifier: "toUsernameVC", sender: nil)
                        }

                    })
                }
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInBtn.isHidden = true

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
