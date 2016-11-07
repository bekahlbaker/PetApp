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
        guard let img = profileImage.image, imageSelected == true else {
            print("Choose an image")
            return
        }

        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_CURRENT_USER.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to image to Firebase")
                } else {
                    print("Successfully uploaded image to Firebase")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        let userInfo: Dictionary<String, Any> = [
                            "profileImgUrl": url as String,
                        ]
                        
                        let firebasePost = DataService.ds.REF_CURRENT_USER
                        firebasePost.updateChildValues(userInfo)
                        
                        self.performSegue(withIdentifier: "toProfileVC2", sender: nil)

                    }
                }
                
            }
            
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
            print("A valid image was not selected.")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

}
