//
//  ProfileVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UITextField!
    @IBOutlet weak var parentsNameLbl: UITextField!
    @IBOutlet weak var ageLbl: UITextField!
    @IBOutlet weak var speciesLbl: UITextField!
    @IBOutlet weak var breedLbl: UITextField!
    @IBOutlet weak var locationLbl: UITextField!
    @IBOutlet weak var aboutLbl: UITextField!
    
    var imagePicker = UIImagePickerController()
    var imagePicked = 0
    
    
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBAction func editCoverPhotoTapped(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("Cover photo chosen")
            imagePicked = 1
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func addImageTapped(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("Profile photo chosen")
            imagePicked = 2
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func tapGestureTapped(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("Profile photo chosen")
            imagePicked = 2
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        ageLbl.delegate = self
        ageLbl.addTarget(self, action: #selector(ProfileVC.textFieldChanged(textField:)) , for: UIControlEvents.editingChanged)
        
        //download profile info & image
        
        DataService.ds.REF_CURRENT_USER.child("user-info").observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.fullNameLbl.text = dictionary["full-name"] as? String
                self.parentsNameLbl.text = dictionary["parents-name"] as? String
                self.ageLbl.text = dictionary["age"] as? String
                self.speciesLbl.text = dictionary["species"] as? String
                self.breedLbl.text = dictionary["breed"] as? String
                self.locationLbl.text = dictionary["location"] as? String
                self.aboutLbl.text = dictionary["about"] as? String
                
                guard let profileUrl = dictionary["profileImgUrl"] as? String else {
                    print("No profile image to download")
                    return
                }
                
                //download profile img
                if profileUrl == (dictionary["profileImgUrl"] as? String)! {
//                    //use Kingfisher
//                    if let imageUrl = URL(string: profileUrl) {
//     
//                        self.profileImg.kf.indicatorType = .activity
//                        self.profileImg.kf.setImage(with: imageUrl)
//                        print("Using kingfisher image for profile.")
//                    } else {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: profileUrl)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                                print("Using firebase image for profile")
                            }
                        }
   
//                    }
                }
            
                guard let coverUrl = dictionary["coverImgUrl"] as? String else {
                    print("No cover image to download")
                    return
                }
                
                //download cover photo
                if coverUrl == (dictionary["coverImgUrl"] as? String)! {
                    //use Kingfisher
//                    if let imageUrl = URL(string: coverUrl) {
//                        self.profileImg.kf.indicatorType = .activity
//                        self.coverPhoto.kf.setImage(with: imageUrl)
//                        print("Using kingfisher image for cover.")
//                    } else {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: coverUrl)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let coverImg = UIImage(data: data!)
                                self.coverPhoto.image = coverImg
                                print("Using firebase image for cover")
                            }
                        }
                        
//                    }
                }
            }
            
            
        })
    }
}
