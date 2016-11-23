//
//  UsernameVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/22/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit

class UsernameVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBAction func checkUsernameTapped(_ sender: AnyObject) {
        
        if usernameTaken == true {
            print("That username is taken. Please try again.")
        } else if usernameTextField.text == "" {
            print("Please enter a username.")
            self.errorLbl.text = "Please enter a username."
        }else {
            let userInfo: Dictionary<String, Any> = [
                "username": usernameTextField.text! as String]
            
            DataService.ds.REF_ACTIVE_USERS
            .childByAutoId().setValue(userInfo)
            
            DataService.ds.REF_CURRENT_USER
            .updateChildValues(userInfo)

            performSegue(withIdentifier: "toProfileVC", sender: nil)
        }

        
    }
    
    var usernameTaken = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(UsernameVC.textFieldDidEndEditing(_:)), for: UIControlEvents.editingChanged)

        
    }
    
    
    func usernameValidation(username: String) {
        
        DataService.ds.REF_ACTIVE_USERS
            .queryOrdered(byChild: "username")
            .queryEqual(toValue: username)
            .observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists(){
                    print("USER: username is available")
                    self.usernameTaken = false
                    self.errorLbl.text = ""
                } else {
                    print("USER: username is taken")
                    self.usernameTaken = true
                    self.errorLbl.text = "That username is taken. Please try again."
                }
            }) { error in
                print(error.localizedDescription)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let username = self.usernameTextField.text
        usernameValidation(username: username!)
    }

}
