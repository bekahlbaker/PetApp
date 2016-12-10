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

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Single Photo VC: \(postKeyPassed)")
        
        if postKeyPassed != "" {
            DataService.ds.REF_POSTS.child(postKeyPassed).observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    
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
                }
            })

        } else {
            print("No post key")
        }
    }
}
