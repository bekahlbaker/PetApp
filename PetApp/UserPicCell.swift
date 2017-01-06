//
//  UserPicCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/11/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UserPicCell: UICollectionViewCell {
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var post: Post!
    static var isConfigured: Bool!
    
    func configureCell(_ post: Post) {
        
        self.post = post
        
        if let imgURL = URL(string: post.imageURL) {
            self.imageView.kf.setImage(with: imgURL)
            print("using kingfisher for feed image")
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
                        }
                    }
                }
            })
        }
    
        UserPicCell.isConfigured = true
    }
    
    
}
