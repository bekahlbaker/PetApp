//
//  UserPicCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/11/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class UserPicCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var currentUser: String!
    var post: Post!
    
    func configureCell() {
        imageView.image = UIImage(named: "loxley-party")
        
//        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: Any] {
//                if let currentUser = dictionary["username"] as? String {
//                    self.currentUser = currentUser
//                    print("CURRENT USER IS: \(currentUser)")
//                }
//            }
//            
//        })
//        
//        DataService.ds.REF_POSTS.queryOrdered(byChild: self.currentUser).queryEqual(toValue: self.currentUser).observeSingleEvent(of: .value, with: { snapshot in
//            if !snapshot.exists(){
//                print("USER: \(self.currentUser)")
//            } else {
//                print("USER: username is taken")
//            }
//        }) { error in
//            print(error.localizedDescription)
//        }

    }
    
    
}
