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
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var resetPassBtn: UIButton!
    @IBAction func loginPressed(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            if passwordField.text == "" {
                self.errorLbl.text = "Please enter a valid password."
            }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.errorLbl.alpha = 1
                            self.errorLbl.text = "Please enter a valid email address."
//                            self.resetPassBtn.isHidden = true
//                            self.signUpBtn.isHidden = true
                        case .errorCodeUserNotFound:
                            self.errorLbl.alpha = 1
                            self.errorLbl.text = "There is not an account for that email. Do you need to sign up?"
//                            self.resetPassBtn.isHidden = true
//                            self.signUpBtn.isHidden = false
                        case .errorCodeTooManyRequests:
                            self.errorLbl.alpha = 1
                            self.errorLbl.text = "Too many requests. Please wait before trying to sign in again."
//                            self.resetPassBtn.isHidden = true
//                            self.signUpBtn.isHidden = true
                        case .errorCodeWrongPassword:
                            self.errorLbl.alpha = 1
                            self.errorLbl.text = "Password is incorrect. Do you need to reset your password?"
//                            self.signUpBtn.isHidden = true
//                            self.resetPassBtn.isHidden = false
                        default:
                            print("Create User Error: \(String(describing: error))")
                        }
                    }
                } else {
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        DataService.ds.completeSignIn(user.uid, userData: userData)
                        print("Email user authenticated with Firebase")
                        if let _ = KeychainWrapper.standard.string(forKey: "Username") {
                            print("Username found in Keychain.")
                            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                        } else {
                            self.performSegue(withIdentifier: "toUsernameVC", sender: nil)
                        }
                    }
                }
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.resetPassBtn.isHidden = true
//        self.signUpBtn.isHidden = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
