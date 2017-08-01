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
    @IBOutlet weak var errorBGView: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var resetPassBtn: UIButton!
    @IBAction func loginPressed(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            if passwordField.text == "" {
                self.showErrorView()
                self.errorLbl.text = "Please enter a valid password."
            }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.showErrorView()
                            self.errorLbl.text = "Please enter a valid email address."
                        case .errorCodeUserNotFound:
                            self.showErrorView()
                            self.errorLbl.text = "There is not an account for that email. Do you need to sign up?"
                        case .errorCodeTooManyRequests:
                            self.showErrorView()
                            self.errorLbl.text = "Too many requests. Please wait before trying to sign in again."
                        case .errorCodeWrongPassword:
                            self.showErrorView()
                            self.errorLbl.text = "Password is incorrect. Do you need to reset your password?"
                        default:
                            print("Create User Error: \(String(describing: error))")
                        }
                    }
                } else {
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        DataService.ds.completeSignIn(user.uid, userData: userData)
                        print("Email user authenticated with Firebase")
                        DataService.ds.REF_CURRENT_USER.child("user-personal").child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let _ = snapshot.value as? NSNull {
                                self.performSegue(withIdentifier: "toUsernameVC", sender: nil)
                            } else {
                                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                            }
                        })
                    }
                }
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        errorBGView.isHidden = true
        errorLbl.isHidden = true
    }
    func showErrorView() {
        if errorBGView.isHidden {
            UIView.animate(withDuration: 0.35) {
                self.errorLbl.isHidden = false
                self.errorBGView.isHidden = false
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func enterAsGuestTapped(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: "example@example.com", password: "123456", completion: { (user, error) in
            if error == nil {
                if let user = user {
                    let userData = ["provider": user.providerID, "IsGuestUser": "true"]
                    DataService.ds.completeSignIn("v2PvUj0ddqVe0kJRoeIWtVZR9dj1", userData: userData)
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        })
        }
}
