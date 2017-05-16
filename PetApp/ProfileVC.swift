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
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UITextField!
    @IBOutlet weak var parentsNameLbl: UITextField!
    @IBOutlet weak var speciesLbl: UITextField!
    @IBOutlet weak var breedLbl: UITextField!
    @IBOutlet weak var locationLbl: UITextField!
    @IBOutlet weak var aboutLbl: UITextField!
    @IBOutlet weak var charCount: UILabel!
    var imagePicker = UIImagePickerController()
    static var profileCache: NSCache<NSString, UIImage> = NSCache()
    let currentUserKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
    @IBAction func addProfileImgTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
        }
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    func alert() {
        let alert = UIAlertController(title: "", message: "If you cancel now, your profile changes will not be saved.", preferredStyle: UIAlertControllerStyle.alert)
        let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { (_) -> Void in
            self.checkIfHasFilledOutProfileOnce { (hasFilledOutProfile) in
                if hasFilledOutProfile {
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    DataService.ds.REF_CURRENT_USER.child("user-personal").updateChildValues(["HasFilledOutProfileOnce": true])
                    self.performSegue(withIdentifier: "FeedVC", sender: nil)
                }
            }
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
        }
        alert.addAction(discard)
        alert.addAction(cancel)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    @IBAction func addBreedTapped(_ sender: Any) {
        breedLbl.alpha = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(alert))
        self.navigationItem.leftBarButtonItem = cancelBtn
        let saveBtn = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem = saveBtn
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        aboutLbl.delegate = self
        aboutLbl.addTarget(self, action: #selector(countAboutLblChar(_:)), for: UIControlEvents.editingChanged)
        downloadUserInfo()
    }
    func downloadUserInfo() {
        //download profile info & image
        DataService.ds.REF_CURRENT_USER.child("user-info").observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                self.fullNameLbl.text = dictionary["full-name"] as? String
                self.parentsNameLbl.text = dictionary["parents-name"] as? String
                self.speciesLbl.text = dictionary["species"] as? String
                self.breedLbl.text = dictionary["breed"] as? String
                self.locationLbl.text = dictionary["location"] as? String
                self.aboutLbl.text = dictionary["about"] as? String
                self.navigationItem.title = dictionary["username"] as? String
                //download profile img
//                self.profileImg.image = UIImage(named: "user-sm")
//                if ProfileVC.profileCache.object(forKey: "\(self.currentUserKey)" as NSString) != nil {
//                    self.profileImg.image = ProfileVC.profileCache.object(forKey: "\(self.currentUserKey)" as NSString)
//                    print("Using cached img")
//                } else {
                    guard let profileUrl = dictionary["profileImgUrl"] as? String else {
                        return
                    }
                    if profileUrl == (dictionary["profileImgUrl"] as? String)! {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: profileUrl)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                            }
                        }
                    }
//                }
            }
        })
    }
}
