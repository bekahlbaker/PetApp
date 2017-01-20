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
    static var profileCache: NSCache<NSString, UIImage> = NSCache()
    static var coverCache: NSCache<NSString, UIImage> = NSCache()
    
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBAction func editCoverPhotoTapped(_ sender: AnyObject) {
//        ProfileVC.coverCache.removeAllObjects()
        let alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        self.imagePicked = 1
        present(alertController, animated: true, completion: nil)
 
    }
    @IBAction func addImageTapped(_ sender: AnyObject) {
//        ProfileVC.profileCache.removeAllObjects()
//        FeedVC.imageCache.removeAllObjects()
        let alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        self.imagePicked = 2
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func tapGestureTapped(_ sender: AnyObject) {
//        ProfileVC.profileCache.removeAllObjects()
//        FeedVC.imageCache.removeAllObjects()
        let alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        self.imagePicked = 2
        present(alertController, animated: true, completion: nil)
    }
    func alert(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "", message: "If you cancel now, your profile changes will not be saved.", preferredStyle: UIAlertControllerStyle.alert)
        let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        alert.addAction(discard)
        alert.addAction(cancel)
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(alert(sender:)))
        self.navigationItem.leftBarButtonItem = cancelBtn
        
        let saveBtn = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = saveBtn
        
//        ProfileVC.profileCache.removeAllObjects()
//        FeedVC.imageCache.removeAllObjects()
//        ProfileVC.coverCache.removeAllObjects()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        ageLbl.delegate = self
        ageLbl.addTarget(self, action: #selector(textFieldChanged(_:)) , for: UIControlEvents.editingChanged)
        
        DispatchQueue.global().async {
            if ProfileVC.profileCache.object(forKey: "profileImg") != nil {
                self.profileImg.image = ProfileVC.profileCache.object(forKey: "profileImg")
                print("Using cached profile img")
            }
            if ProfileVC.coverCache.object(forKey: "coverImg") != nil {
                self.coverPhoto.image = ProfileVC.coverCache.object(forKey: "coverImg")
                print("Using cached cover Img")
            }
        }
        
        downloadUserInfo()
    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        downloadUserInfo()
//    }
    
    func downloadUserInfo() {
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
                //download profile img
//                if ProfileVC.profileCache.object(forKey: "profileImg") != nil {
//                    self.profileImg.image = ProfileVC.profileCache.object(forKey: "profileImg")
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
                //download cover photo
//                if ProfileVC.coverCache.object(forKey: "coverImg") != nil {
//                    self.coverPhoto.image = ProfileVC.coverCache.object(forKey: "coverImg")
//                } else {
                    guard let coverUrl = dictionary["coverImgUrl"] as? String else {
                        return
                    }
                    if coverUrl == (dictionary["coverImgUrl"] as? String)! {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: coverUrl)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let coverImg = UIImage(data: data!)
                                self.coverPhoto.image = coverImg
                            }
                        }
                    }
//                }
            }
            
        })
    }
}
