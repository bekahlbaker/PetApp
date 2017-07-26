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
    @IBOutlet weak var errorBGView: UIView!
    @IBOutlet weak var signInBtn: UIButton!
    var isOver18 = false
    var didReadAgreements = false
    @IBOutlet weak var checkboxForAge: UIButton!
    @IBAction func checkboxForAgeTapped(_ sender: Any) {
        if !isOver18 {
            isOver18 = true
            checkboxForAge.setImage(UIImage(named: "checked-box"), for: .normal)
        } else {
            isOver18 = false
            checkboxForAge.setImage(UIImage(named: "box"), for: .normal)
        }
    }
    @IBOutlet weak var checkboxForTOS: UIButton!
    @IBAction func checkboxForTOSTapped(_ sender: Any) {
        if !didReadAgreements {
            didReadAgreements = true
            checkboxForTOS.setImage(UIImage(named: "checked-box"), for: .normal)
        } else {
            didReadAgreements = false
            checkboxForTOS.setImage(UIImage(named: "box"), for: .normal)
        }
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
    @IBAction func logInPressed(_ sender: RoundedCornerButton) {
        if passwordField.text == "" {
            showErrorView()
            self.errorLbl.text = "Please enter a valid password."
        } else if passwordField.text != password2.text {
            showErrorView()
            self.errorLbl.text = "Your passwords do not match. Please try again."
        } else if isOver18 == false || didReadAgreements == false {
            showErrorView()
            self.errorLbl.text = "Please be sure you have checked the agreement boxes before creating an account."
        } else if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.showErrorView()
                            self.errorLbl.text = "Please enter a valid email address."
                        //                            self.signInBtn.isHidden = true
                        case .errorCodeEmailAlreadyInUse:
                            self.showErrorView()
                            self.errorLbl.text = "This email is already in use. Do you need to sign in?"
                        //                            self.signInBtn.isHidden = false
                        case .errorCodeWeakPassword:
                            self.showErrorView()
                            self.errorLbl.text = "Your password needs to be at least 6 characters. Please enter a new password."
                        //                            self.signInBtn.isHidden = true
                        default:
                            print("Create User Error: \(String(describing: error))")
                        }
                    }
                } else {
                    print("Successfully authenticated with Firebase using email")
                    if let user = user {
                        let userData = ["provider": user.providerID, "email": email, "IsOver18": "true", "DidReadAgreements": "true"]
                        DataService.ds.completeSignIn(user.uid, userData: userData)
                        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues([user.uid: true])
                        DataService.ds.REF_CURRENT_USER.child("followers").updateChildValues([user.uid: true])
                        self.addAutoFollowing()
                    }
                    self.performSegue(withIdentifier: "toUsernameVC", sender: nil)
                }
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        errorBGView.isHidden = true
        errorLbl.isHidden = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    func showErrorView() {
        if errorBGView.isHidden {
            UIView.animate(withDuration: 0.35) {
                self.errorLbl.isHidden = false
                self.errorBGView.isHidden = false
            }
        }
    }
    func addAutoFollowing() {
        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["8QcWittLktYDQsCXDt274XSJYMR2": true])
        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["A3v26EF36pMUNlLh62GXwDWKn6k2": true])
        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["CsoDtpveDIhqWPlVc8mCEEWxGlp1": true])
        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["sBsROT2OywOlMcKxbXFj6a1C9tq1": true])
        DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["v2PvUj0ddqVe0kJRoeIWtVZR9dj1": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfBYx1XT796QW_Uiqj": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfDPSLGxlPNBQoiJKu": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfG6r_wN7a5bURVjyl": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfLJWbACRSBOdPMJuF": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfLcTG1KfRtnIEAc2Y": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfLpbvyW9rrePONhbu": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfLyA7s67LtK9T71KJ": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfMRA_8x7uMgZMS4c4": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfMbWpI4BL3sHLQOVt": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfMivCE6XR7Z6DK0I-": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfNFNI6yMEVxuvRoOg": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfNLfbIMvJpFRhx36V": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfPC7Jj4Ia2JPyd0PQ": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfPJyl2WwRLY0f7nzy": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfPRGyOENe7R_HkAx2": true])
        DataService.ds.REF_CURRENT_USER.child("wall").updateChildValues(["-KnfPWmDusnXBeN76G4O": true])
    }
}
