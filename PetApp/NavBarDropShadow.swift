//
//  NavBarDropShadow.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit

class NavBarDropShadow: UINavigationBar {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowColor = UIColor.gray.cgColor
    }
}
