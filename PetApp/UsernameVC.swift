//
//  UsernameVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/22/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class UsernameVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBAction func checkUsernameTapped(_ sender: AnyObject) {
        if usernameTextField.text == "" {
            self.errorLbl.text = "Please enter a username."
        } else {
            if (usernameTextField.text?.characters.contains { [".", "#", "$", "[", "]"].contains( $0 ) })! {
                self.errorLbl.text = "Username cannot contain \n '.' '#' '$' '[' or ']' \n please try again."
            } else {
                if let username = usernameTextField.text {
                    let userInfo: [String: Any] = [
                        "username": username]
                    DataService.ds.REF_ACTIVE_USERS.updateChildValues([username: true])
                    DataService.ds.REF_CURRENT_USER.child("user-personal").updateChildValues(userInfo)
                    DataService.ds.REF_CURRENT_USER.child("user-info").updateChildValues(userInfo)
                    KeychainWrapper.standard.set(username, forKey: "Username")
                    performSegue(withIdentifier: "toProfileVC", sender: nil)
                }
            }
        }
    }
    var usernameTaken = false
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(UsernameVC.textFieldDidEndEditing(_:)), for: UIControlEvents.editingChanged)
    }
    func usernameValidation(username: String) {
        print("USERNAME TO CHECK: \(username)")
            DataService.ds.REF_ACTIVE_USERS.child(username).observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.usernameTaken = false
                    self.errorLbl.text = ""
                } else {
                    self.usernameTaken = true
                    self.errorLbl.text = "That username is taken. Please try again."
                }
            })
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let username = self.usernameTextField.text
        if username != "" {
            if (username?.characters.contains { [".", "#", "$", "[", "]"].contains( $0 ) })! {
                self.errorLbl.text = "Username cannot contain \n '.' '#' '$' '[' or ']' \n please try again."
            } else {
                usernameValidation(username: username!)
            }
        }
    }
}
