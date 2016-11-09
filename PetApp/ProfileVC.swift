//
//  ProfileVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class ProfileVC: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let reference = DataService.ds.REF_USER_PROFILE
        let imageView: UIImageView = profileImg
        imageView.sd_setImage(with: reference)
    
    }

}
