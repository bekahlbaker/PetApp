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
    func save() {
        if KeychainWrapper.standard.string(forKey: KEY_UID)! as String != "v2PvUj0ddqVe0kJRoeIWtVZR9dj1" {
            if self.profileImg.image != nil {
                let imageName = UUID().uuidString
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/png"
                if let uploadData = UIImageJPEGRepresentation(self.profileImg.image!, 0.2) {
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
            //save profile info
            createUserInfo("full-name", value: self.fullNameLbl.text! as String)
            createUserInfo("parents-name", value: parentsNameLbl.text! as String)
            createUserInfo("species", value: speciesLbl.text! as String)
            createUserInfo("breed", value: breedLbl.text! as String)
            createUserInfo("location", value: locationLbl.text! as String)
            createUserInfo("about", value: aboutLbl.text! as String)
            DataService.ds.REF_CURRENT_USER.child("user-personal").child("HasFilledOutProfileOnce").observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    DataService.ds.REF_CURRENT_USER.child("user-personal").updateChildValues(["HasFilledOutProfileOnce": true])
                    self.performSegue(withIdentifier: "FeedVC", sender: nil)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            let alert = UIAlertController(title: "You cannot edit this profile while viewing as a guest.", message: "Please log out and create your own account.", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    func createUserInfo(_ key: String, value: String) {
        let userInfo: [String: Any] = [
            key: value
        ]
        let firebasePost = DataService.ds.REF_CURRENT_USER.child("user-info")
        firebasePost.updateChildValues(userInfo)
    }
    func countAboutLblChar(_ textField: UITextField) {
        let text = textField.text
        let count = text?.characters.count
        let charLeft = 140 - count!
        self.charCount.text = String(charLeft)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = pickedImage
        }
//        ProfileVC.profileCache.removeAllObjects()
        FeedVC.imageCache.removeAllObjects()
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
