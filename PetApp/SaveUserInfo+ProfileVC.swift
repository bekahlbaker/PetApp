//
//  SaveUserInfo+ProfileVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/2/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

extension ProfileVC {
    //SAVE and UPLOAD profile info & image
    
    @IBAction func saveBtnPressed(_ sender: AnyObject) {
        ProfileVC.profileCache.removeAllObjects()
        ProfileVC.coverCache.removeAllObjects()
        FeedVC.imageCache.removeAllObjects()
        
        if self.profileImg.image != nil {
            //save profile image
            let imageName = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            if let uploadData = UIImagePNGRepresentation(self.profileImg.image!) {
                DataService.ds.REF_USER_PROFILE.child(imageName).put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    if let profileImageUrl =  metadata?.downloadURL()?.absoluteString {
                        self.createUserInfo(key: "profileImgUrl", value: profileImageUrl)
                        print("Successfuly uploaded image to Firebase")
                    }
                })
            }
        } else {
            print("No profile image to save")
        }
        
        
        if self.coverPhoto.image != nil {
            //save cover image
            let coverImageName = NSUUID().uuidString
            let coverMetadata = FIRStorageMetadata()
            coverMetadata.contentType = "image/png"
            
            if let uploadData = UIImagePNGRepresentation(self.coverPhoto.image!) {
                DataService.ds.REF_USER_COVER.child(coverImageName).put(uploadData, metadata: coverMetadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    if let coverImageUrl =  metadata?.downloadURL()?.absoluteString {
                        self.createUserInfo(key: "coverImgUrl", value: coverImageUrl)
                        print("Successfuly uploaded cover image to Firebase")
                    }
                })
            }
        } else {
            print("No cover image to save")
        }
        
        //save profile info
        
        if self.fullNameLbl.text != "" {
            self.createUserInfo(key: "full-name", value: self.fullNameLbl.text! as String)
        } else {
            self.removeUserInfo(key: "full-name")
        }
        if self.parentsNameLbl.text != "" {
            self.createUserInfo(key: "parents-name", value: parentsNameLbl.text! as String)
        } else {
            self.removeUserInfo(key: "parents-name")
        }
        if ageLbl.text != "" {
            self.createUserInfo(key: "age", value: ageLbl.text! as String)
        } else {
            self.removeUserInfo(key: "age")
        }
        if speciesLbl.text != "" {
            self.createUserInfo(key: "species", value: speciesLbl.text! as String)
        } else {
            self.removeUserInfo(key: "species")
        }
        if breedLbl.text != "" {
            self.createUserInfo(key: "breed", value: breedLbl.text! as String)
        } else {
            self.removeUserInfo(key: "breed")
        }
        if locationLbl.text != "" {
            self.createUserInfo(key: "location", value: locationLbl.text! as String)
        } else {
            self.removeUserInfo(key: "location")
        }
        if aboutLbl.text != "" {
            self.createUserInfo(key: "about", value: aboutLbl.text! as String)
        } else {
            self.removeUserInfo(key: "about")
        }
        performSegue(withIdentifier: "toUserVC", sender: nil)
    }
    
    func createUserInfo(key: String, value: String) {
        let userInfo: Dictionary<String, Any> = [
            key: value
        ]
        let firebasePost = DataService.ds.REF_CURRENT_USER.child("user-info")
        firebasePost.updateChildValues(userInfo)
    }
    
    func removeUserInfo(key: String) {
        let userInfoRef = DataService.ds.REF_CURRENT_USER.child("user-info")
        userInfoRef.child(key).removeValue()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
