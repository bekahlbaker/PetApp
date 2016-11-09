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
        let img = profileImage.image
        
        if let imgData = UIImageJPEGRepresentation(img!, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "images/jpeg"
            
            DataService.ds.REF_USER_PROFILE.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error)
                } else {
                    print("Successfully uploaded image to Firebase")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.uploadToFirebase(imgUrl: url)
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
            print("Valid image not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebase(imgUrl: String) {
        let userInfo: Dictionary<String, Any> = [
           "imageUrl": imgUrl as String
        ]
        
        let firebasePost = DataService.ds.REF_CURRENT_USER
        firebasePost.updateChildValues(userInfo)
        
        performSegue(withIdentifier: "toProfileVC2", sender: nil)
    }
    

}
