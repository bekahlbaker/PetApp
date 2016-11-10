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
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var parentsNameLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var speciesLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //download profile info
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                print(snapshot)
                self.usernameLabel.text = dictionary["username"] as? String
                self.fullNameLbl.text = dictionary["full-name"] as? String
                self.parentsNameLbl.text = dictionary["parents-name"] as? String
                self.ageLbl.text = dictionary["age"] as? String
                self.speciesLbl.text = dictionary["species"] as? String
                self.breedLbl.text = dictionary["breed"] as? String
            }
            
            
            })

        
        
        //download profile image
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: Any] {
                let url = dictionary["profileImgUrl"] as! String
                let storage = FIRStorage.storage()
                
                let storageRef = storage.reference(forURL: url)
                
                storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                    if error != nil {
                        print("Unablet to download image from firebase")
                    } else {
                        let profileImg = UIImage(data: data!)
                        self.profileImg.image = profileImg
                    }
                }
                

            }
        })
        
    }

}
