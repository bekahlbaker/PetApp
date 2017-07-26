//
//  EntryVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class EntryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
//        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("ID and username found in Keychain.")
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        } else {
//            print(KeychainWrapper.standard.string(forKey: KEY_UID))
            print("No user found")
        }
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("\(key) = \(value) \n")
//        }
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
