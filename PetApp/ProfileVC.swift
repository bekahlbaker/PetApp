//
//  ProfileVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase


class ProfileVC: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                print(snapshot)
                self.usernameLabel.text = dictionary["username"] as? String
            }
            
            })

        
        
        //download profile image
        
//        let url = DataService.ds.REF_CURRENT_USER.child("profileImgUrl")
//        
//        print("THE PROFILE IMG URL IS \(url)")
//        
//        let localUrl = url as! String
//        
//        let reference = FIRStorage.storage().reference(forURL: url)
//        
//        reference.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
//            if error != nil {
//                print("Unable to download from Firebase storage")
//                return
//            }
//            
//            print("Image downloaded")
//            self.profileImg.image = UIImage(data: data!)
//        }
        
    }

}
