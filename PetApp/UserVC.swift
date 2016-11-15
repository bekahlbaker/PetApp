//
//  UserVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/11/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class UserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    @IBOutlet weak var parentsNameLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //download user info & image

        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.usernameLbl.text = dictionary["username"] as? String
                self.fullNameLbl.text = dictionary["full-name"] as? String
                self.parentsNameLbl.text = dictionary["parents-name"] as? String
                self.ageLbl.text = dictionary["age"] as? String
                self.breedLbl.text = dictionary["breed"] as? String
                self.aboutLbl.text = dictionary["about"] as? String
                if let url = dictionary["profileImgUrl"] as? String {
                    let storage = FIRStorage.storage()
                    
                    let storageRef = storage.reference(forURL: url)
                    
                    storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("Unable to download image from firebase")
                        } else {
                            let profileImg = UIImage(data: data!)
                            self.profileImg.image = profileImg
                            
                        }
                    }
                    
                } else {
                    self.profileImg.image = UIImage(named: "add-image")
                }
            }
            
            
        })
        
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPicCell", for: indexPath) as? UserPicCell {
            cell.configureCell()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105 , height: 105)
    }
}
