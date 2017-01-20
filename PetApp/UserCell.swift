//
//  UserCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/20/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    var user: User!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureUser(_ user: User) {
        self.user = user
        
        self.nameLabel.text = user.name
    }
}
