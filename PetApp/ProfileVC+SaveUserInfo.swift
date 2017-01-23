//
//  ProfileVC+SaveUserInfo.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/2/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper

extension ProfileVC {
    //SAVE and UPLOAD profile info & image
    func save(sender: UIBarButtonItem) {
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
                    }
                })
            }
        } else {
            print("No cover image to save")
        }
        //save profile info
        createUserInfo("full-name", value: self.fullNameLbl.text! as String)
        createUserInfo("parents-name", value: parentsNameLbl.text! as String)
        createUserInfo("age", value: ageLbl.text! as String)
        createUserInfo("species", value: speciesLbl.text! as String)
        createUserInfo("breed", value: breedLbl.text! as String)
        createUserInfo("location", value: locationLbl.text! as String)
        createUserInfo("about", value: aboutLbl.text! as String)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshCurrentUserVC"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func createUserInfo(_ key: String, value: String) {
        let userInfo: Dictionary<String, Any> = [
            key: value
        ]
        let firebasePost = DataService.ds.REF_CURRENT_USER.child("user-info")
        firebasePost.updateChildValues(userInfo)
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
        ProfileVC.profileCache.removeAllObjects()
        FeedVC.imageCache.removeAllObjects()
        ProfileVC.coverCache.removeAllObjects()
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
