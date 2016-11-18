//
//  PostVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var captionTextField: UITextView!
    
    @IBOutlet weak var postImage: UIImageView!
    @IBAction func imagePickerTapped(_ sender: AnyObject) {
        present(postImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePost(_ sender: AnyObject) {
        
        guard let img = postImage.image, imageSelected == true else {
            print("Please choose an image")
            return
        }
        
        if let imgData = UIImagePNGRepresentation(img){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            DataService.ds.REF_POST_IMGS.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to image to Firebase")
                } else {
                    print("Successfully uploaded image to Firebase")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imageURL: url)
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                    }
                }
                
            }
            
        }

        }
    
    var currentUser: String!
    var postImagePicker: UIImagePickerController!
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImagePicker = UIImagePickerController()
        postImagePicker.delegate = self
        postImagePicker.allowsEditing = true

        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let currentUser = dictionary["username"] as? String
//                let profileImgUrl = dictionary["profileImgUrl"] as? String
            
                self.currentUser = currentUser
//                self.profileImgUrl = profileImgUrl
            }

        })
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            postImage.image = image
            imageSelected = true
        } else {
            print("Valid image not selected.")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func postToFirebase(imageURL: String) {
        let post: Dictionary<String, Any> = [
            "caption": captionTextField.text! as String,
            "username": self.currentUser as String,
            "imageURL": imageURL as String
//            "profileImgUrl": self.profileImgUrl as String
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionTextField.text = ""
        imageSelected = false
        postImage.image = UIImage(named: "add-image")
        
        print("POST: \(post)")

    }

}
