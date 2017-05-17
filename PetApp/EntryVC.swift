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
    }
    override func viewDidAppear(_ animated: Bool) {
//        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("ID and username found in Keychain.")
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        } else {
            print(KeychainWrapper.standard.string(forKey: KEY_UID))
        }
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("\(key) = \(value) \n")
//        }
    }
}
