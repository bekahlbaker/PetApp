//
//  ProfileVC1.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/7/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC1: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: CircleImage!
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func nextBtnTapped(_ sender: AnyObject) {
        
        let imageName = NSUUID().uuidString
        
        
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!) {
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        print(metadata)
                        
                        if let profileImageUrl =  metadata?.downloadURL()?.absoluteString {
                         let values = ["profileImgUrl": profileImageUrl]
                            
                        self.uploadToFirebase(values: values)
                        
                            print("Successfuly uploaded image to Firebase")
                        }
                        
                    })
        }
    
}
    
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
            imageSelected = true
        } else {
            print("Valid image not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadToFirebase(values: [String: Any]) {
        let firebasePost = DataService.ds.REF_CURRENT_USER
        firebasePost.updateChildValues(values)
        
        performSegue(withIdentifier: "toProfileVC2", sender: nil)
    }
    
}
