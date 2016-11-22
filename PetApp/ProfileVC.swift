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
    @IBOutlet weak var usernameLabel: UITextField!
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
        
//        checkForUsername(username: self.usernameLabel.text!)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        ageLbl.delegate = self
        ageLbl.addTarget(self, action: #selector(ProfileVC.textFieldChanged(textField:)) , for: UIControlEvents.editingChanged)
        
        //download profile info & image
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.fullNameLbl.text = dictionary["full-name"] as? String
                self.parentsNameLbl.text = dictionary["parents-name"] as? String
                self.ageLbl.text = dictionary["age"] as? String
                self.speciesLbl.text = dictionary["species"] as? String
                self.breedLbl.text = dictionary["breed"] as? String
                self.locationLbl.text = dictionary["location"] as? String
                self.aboutLbl.text = dictionary["about"] as? String
                //download profile img
                if let url = dictionary["profileImgUrl"] as? String {
                    //use Kingfisher
                    if let imageUrl = URL(string: url) {
                        self.profileImg.kf.indicatorType = .activity
                        self.profileImg.kf.setImage(with: imageUrl)
                        print("Using kingfisher image for profile.")
                    } else {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: url)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                                print("Using firebase image for profile")
                            }
                        }
   
                    }
                }
                //download cover photo
                if let url = dictionary["coverImgUrl"] as? String {
                    //use Kingfisher
                    if let imageUrl = URL(string: url) {
                        self.profileImg.kf.indicatorType = .activity
                        self.coverPhoto.kf.setImage(with: imageUrl)
                        print("Using kingfisher image for cover.")
                    } else {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: url)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let coverImg = UIImage(data: data!)
                                self.coverPhoto.image = coverImg
                                print("Using firebase image for cover")
                            }
                        }
                        
                    }
                }
            }
            
            
        })
    }
    
    //SAVE and UPLOAD profile info & image
    
    @IBAction func saveBtnPressed(_ sender: AnyObject) {
        
        
        
            let imageName = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            if let uploadData = UIImagePNGRepresentation(self.profileImg.image!) {
               DataService.ds.REF_USER_PROFILE.child(imageName).put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if let profileImageUrl =  metadata?.downloadURL()?.absoluteString {
                        let values = ["profileImgUrl": profileImageUrl]
                        self.uploadToFirebase(values: values)
                        print("Successfuly uploaded image to Firebase")
                    }
                })
            }
            
            //save cover image
            let coverImageName = NSUUID().uuidString
            let coverMetadata = FIRStorageMetadata()
            coverMetadata.contentType = "image/png"
            
            if let uploadData = UIImagePNGRepresentation(self.coverPhoto.image!) {
                DataService.ds.REF_USER_COVER.child(coverImageName).put(uploadData, metadata: coverMetadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if let coverImageUrl =  metadata?.downloadURL()?.absoluteString {
                        let values = ["coverImgUrl": coverImageUrl]
                        self.uploadToFirebase(values: values)
                        print("Successfuly uploaded cover image to Firebase")
                    }
                })
            }
            
            //save profile info
            
            if usernameLabel.text == "" {
                errorLbl.text = "Please enter a username."
            }else {
                let userInfo: Dictionary<String, Any> = [
                    "username": usernameLabel.text! as String,
                    "full-name": fullNameLbl.text! as String,
                    "parents-name": parentsNameLbl.text! as String,
                    "age": ageLbl.text! as String,
                    "species": speciesLbl.text! as String,
                    "breed": breedLbl.text! as String,
                    "location": locationLbl.text! as String,
                    "about": aboutLbl.text! as String
                ]
                
                let firebasePost = DataService.ds.REF_CURRENT_USER
                firebasePost.updateChildValues(userInfo)
                performSegue(withIdentifier: "toUserVC", sender: nil)
            }
    }
    
    func textFieldChanged(textField: UITextField) {
        let ageEntered = ageLbl.text
        if textField.text != "" {
            textField.text = "\(ageEntered!) yo"
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if imagePicked == 1 {
            coverPhoto.image = pickedImage
        } else if imagePicked == 2 {
            profileImg.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebase(values: [String: Any]) {
        let firebasePost = DataService.ds.REF_CURRENT_USER
        firebasePost.updateChildValues(values)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
