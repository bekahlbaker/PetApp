//
//  UserPicCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/11/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class UserPicCell: UICollectionViewCell {
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var post: Post!
    
    func configureCell(post: Post, img: UIImage? = nil) {
//        activitySpinner.startAnimating()
        
        self.post = post
        
        if img != nil {
//            self.activitySpinner.stopAnimating()
            self.imageView.image = img
        } else {
            self.imageView.image = UIImage(named: "")
            let ref = FIRStorage.storage().reference(forURL: post.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    self.imageView.image = UIImage(named: "")
                    print("Unable to download user image")
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.imageView.image = img
//                            self.activitySpinner.stopAnimating()
                            UserVC.userImageCache.setObject(img, forKey: post.imageURL as NSString)
                        }
                    }
                }
            })
        }
    
    }
    
    
}
