//
//  RoundedCornerButton.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit

class RoundedCornerButton: UIButton {
        
    override func awakeFromNib() {
        super.awakeFromNib()
            
        self.layer.cornerRadius = 3.0
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowRadius = 3.0
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        self.layer.shadowColor = UIColor.gray.cgColor
    }

}
