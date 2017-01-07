//
//  User.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/14/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    fileprivate var _followers: Int!
    fileprivate var _following: Int!
    
    var followers: Int {
        return _followers
    }
    
    var following: Int {
        return _following
    }
    
    init(followers: Int, following: Int) {
        self._followers = followers
        self._following = following
    }
    
    func adjustFollowers(_ addFollower: Bool) {
        if addFollower {
            _followers = _followers + 1
        } else {
            _followers = _followers - 1
        }
        
        DataService.ds.REF_CURRENT_USER.updateChildValues(["followers": followers])
    }
    
    func adjustFollowing(_ addFollowing: Bool) {
        if addFollowing {
            _following = _following + 1
        } else {
            _following = _following - 1
        }
        
        DataService.ds.REF_CURRENT_USER.updateChildValues(["following": following])
    }
}
