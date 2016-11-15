//
//  ProfileVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase


class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var fullNameLbl: UITextField!
    @IBOutlet weak var parentsNameLbl: UITextField!
    @IBOutlet weak var ageLbl: UITextField!
    @IBOutlet weak var speciesLbl: UITextField!
    @IBOutlet weak var breedLbl: UITextField!
    @IBOutlet weak var aboutLbl: UITextField!
    
    @IBOutlet weak var profileImage: CircleImage!
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func tapGestureTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        //download profile info & image
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.usernameLabel.text = dictionary["username"] as? String
                self.fullNameLbl.text = dictionary["full-name"] as? String
                self.parentsNameLbl.text = dictionary["parents-name"] as? String
                self.ageLbl.text = dictionary["age"] as? String
                self.speciesLbl.text = dictionary["species"] as? String
                self.breedLbl.text = dictionary["breed"] as? String
                self.aboutLbl.text = dictionary["about"] as? String
                if let url = dictionary["profileImgUrl"] as? String {
                    let storage = FIRStorage.storage()
                    let storageRef = storage.reference(forURL: url)
                    storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("Unable to download image from firebase")
                        } else {
                            let profileImg = UIImage(data: data!)
                            self.profileImg.image = profileImg
                        }
                    }
                    
                } else {
                    self.profileImg.image = UIImage(named: "add-image")
                }
            }
            
            
        })
    }
    
    @IBAction func saveBtnPressed(_ sender: AnyObject) {
      //save profile image
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
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

        //save profile info
        
        let userInfo: Dictionary<String, Any> = [
            "username": usernameLabel.text! as String,
            "full-name": fullNameLbl.text! as String,
            "parents-name": parentsNameLbl.text! as String,
            "age": ageLbl.text! as String,
            "species": speciesLbl.text! as String,
            "breed": breedLbl.text! as String,
            "about": aboutLbl.text! as String
        ]
        
        let firebasePost = DataService.ds.REF_CURRENT_USER
        firebasePost.updateChildValues(userInfo)
        performSegue(withIdentifier: "toUserVC", sender: nil)
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
