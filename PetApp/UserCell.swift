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
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var parentsNameLabel: UILabel!
    @IBOutlet weak var ageBreedSpeciesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureUser(_ user: User) {
        self.user = user
        
        self.nameLabel.text = user.name
        self.parentsNameLabel.text = user.parentsName
        self.locationLabel.text = user.location
        self.aboutLabel.text = user.about
//        self.followersLabel.text = String(user.followers)
//        self.followingLabel.text = String(user.following)
        
        if user.age != "" {
            self.ageBreedSpeciesLabel.text = user.age
            if user.breed != "" {
                self.ageBreedSpeciesLabel.text = user.age + " " + user.breed
            } else {
                if user.species != "" {
                    self.ageBreedSpeciesLabel.text = user.age + " " + user.species
                }
            }
        } else {
            if user.breed != "" {
                self.ageBreedSpeciesLabel.text = user.breed
            } else {
                if user.species != "" {
                    self.ageBreedSpeciesLabel.text = user.species
                }
            }
        }
    }
}
