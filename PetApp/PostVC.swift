//
//  PostVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class PostVC: UIViewController {
    
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBAction func savePost(_ sender: AnyObject) {
            postToFirebase()
        }
    
    var currentUser: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let currentUser = dictionary["username"] as? String
            
            print("Username: \(currentUser!)")
            self.currentUser = currentUser
            }

        })
    }
    
    func postToFirebase() {
        let post: Dictionary<String, Any> = [
            "caption": captionTextField.text! as String,
            "username": self.currentUser as String,
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        print("POST: \(post)")

    }

}
