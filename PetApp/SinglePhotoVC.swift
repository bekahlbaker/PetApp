//
//  SinglePhotoVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class SinglePhotoVC: UIViewController {
    
    var postKeyPassed: String!
    
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var usernameLbl: UIButton!
    @IBOutlet weak var likeBtn: UIImageView!
    @IBOutlet weak var captionTxtView: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func likeBtnTapped(_ sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Single Photo VC: \(postKeyPassed)")
        
        if postKeyPassed != "" {
            DataService.ds.REF_POSTS.child(postKeyPassed).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    if let username = dictionary["username"] as? String {
                        self.usernameLbl.setTitle(username, for: .normal)   
                    }
                    
                    if let caption = dictionary["caption"] as? String {
                        self.captionTxtView.text = caption
                    }
                    
                    if let likes = dictionary["likes"] as? Int {
                        self.likesLbl.text = String(likes)
                    }
                    
                    guard let imgURL = dictionary["imageURL"] as? String else {
                        print("No image to download")
                        return
                    }
                    
                    //download img
                    if imgURL == (dictionary["imageURL"] as? String)! {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: imgURL)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let img = UIImage(data: data!)
                                self.imageView.image = img
                            }
                        }
                    }
                    
                    guard let profileImgUrl = dictionary["profileImgUrl"] as? String else {
                        print("No profile image to download")
                        return
                    }
                    
                    //download profile img
                    if profileImgUrl == (dictionary["profileImgUrl"] as? String)! {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: imgURL)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download profile image from firebase")
                            } else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                            }
                        }
                    }
                }
            })

        } else {
            print("No post key")
        }
    }
}
