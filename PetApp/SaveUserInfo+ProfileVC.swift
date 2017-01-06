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
        if self.profileImg.image != nil {
            ProfileVC.profileCache.setObject(self.profileImg.image!, forKey: "profileImg")
            //save profile image
            let imageName = UUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            if let uploadData = UIImagePNGRepresentation(self.profileImg.image!) {
                DataService.ds.REF_USER_PROFILE.child(imageName).put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    if let profileImageUrl =  metadata?.downloadURL()?.absoluteString {
                        self.createUserInfo("profileImgUrl", value: profileImageUrl)
                        print("Successfuly uploaded image to Firebase")
                    }
                })
            }
        } else {
            print("No profile image to save")
        }
        
        
        if self.coverPhoto.image != nil {
            ProfileVC.coverCache.setObject(self.coverPhoto.image!, forKey: "coverImg")
            //save cover image
            let coverImageName = UUID().uuidString
            let coverMetadata = FIRStorageMetadata()
            coverMetadata.contentType = "image/png"
            
            if let uploadData = UIImagePNGRepresentation(self.coverPhoto.image!) {
                DataService.ds.REF_USER_COVER.child(coverImageName).put(uploadData, metadata: coverMetadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    if let coverImageUrl =  metadata?.downloadURL()?.absoluteString {
                        self.createUserInfo("coverImgUrl", value: coverImageUrl)
                        print("Successfuly uploaded cover image to Firebase")
                    }
                })
            }
        } else {
            print("No cover image to save")
        }
        
        //save profile info
        
        if self.fullNameLbl.text != "" {
            self.createUserInfo("full-name", value: self.fullNameLbl.text! as String)
        } else {
            self.removeUserInfo("full-name")
        }
        if self.parentsNameLbl.text != "" {
            self.createUserInfo("parents-name", value: parentsNameLbl.text! as String)
        } else {
            self.removeUserInfo("parents-name")
        }
        if ageLbl.text != "" {
            self.createUserInfo("age", value: ageLbl.text! as String)
        } else {
            self.removeUserInfo("age")
        }
        if speciesLbl.text != "" {
            self.createUserInfo("species", value: speciesLbl.text! as String)
        } else {
            self.removeUserInfo("species")
        }
        if breedLbl.text != "" {
            self.createUserInfo("breed", value: breedLbl.text! as String)
        } else {
            self.removeUserInfo("breed")
        }
        if locationLbl.text != "" {
            self.createUserInfo("location", value: locationLbl.text! as String)
        } else {
            self.removeUserInfo("location")
        }
        if aboutLbl.text != "" {
            self.createUserInfo("about", value: aboutLbl.text! as String)
        } else {
            self.removeUserInfo("about")
        }
        performSegue(withIdentifier: "ViewUserVC", sender: nil)
    }
    
    func createUserInfo(_ key: String, value: String) {
        let userInfo: Dictionary<String, Any> = [
            key: value
        ]
        let firebasePost = DataService.ds.REF_CURRENT_USER.child("user-info")
        firebasePost.updateChildValues(userInfo)
    }
    
    func removeUserInfo(_ key: String) {
        let userInfoRef = DataService.ds.REF_CURRENT_USER.child("user-info")
        userInfoRef.child(key).removeValue()
    }
    
    func textFieldChanged(_ textField: UITextField) {
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
