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
    
    fileprivate var _userKey: String!
    fileprivate var _username: String!
    fileprivate var _name: String!
    fileprivate var _parentsName: String!
    fileprivate var _age: String!
    fileprivate var _species: String!
    fileprivate var _breed: String!
    fileprivate var _location: String!
    fileprivate var _about: String!
    fileprivate var _followers: Int!
    fileprivate var _following: Int!
    
    var userKey: String {
        return _userKey
    }
    
    var username: String {
        return _username
    }
    
    var name: String {
        return _name
    }
    
    var parentsName: String {
        return _parentsName
    }
    
    var age: String {
        return _age
    }
    
    var species: String {
        return _species
    }
    
    var breed: String {
        return _breed
    }
    
    var location: String {
        return _location
    }
    
    var about: String {
        return _about
    }
    
    var followers: Int {
        return _followers
    }
    
    var following: Int {
        return _following
    }
    
    init(username: String, name: String, parentsName: String, age: String, species: String, breed: String, location: String, about: String, followers: Int, following: Int) {
        self._username = username
        self._name = name
        self._parentsName = parentsName
        self._age = age
        self._species = species
        self._breed = breed
        self._location = location
        self._about = about
        self._followers = followers
        self._following = following
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let username = userData["username"] as? String {
            self._username = username
        }
        
        if let name = userData["full-name"] as? String {
            self._name = name
        }
        if let parentsName = userData["parents-name"] as? String {
            self._parentsName = parentsName
        }
        if let age = userData["age"] as? String {
            self._age = age
        }
        if let species = userData["species"] as? String {
            self._species = species
        }
        if let breed = userData["breed"] as? String {
            self._breed = breed
        }
        if let location = userData["location"] as? String {
            self._location = location
        }
        if let about = userData["about"] as? String {
            self._about = about
        }
        
        if let followers = userData["followersCt"] as? Int {
            self._followers = followers
        }
        
        if let following = userData["followingCt"] as? Int {
            self._following = following
        }
    }
    
    func adjustFollowers(userKey: String, _ addFollower: Bool) {
        if addFollower {
            _followers = _followers + 1
        } else {
            _followers = _followers - 1
        }
        
        DataService.ds.REF_USERS.child(userKey).child("user-info").updateChildValues(["followersCt": followers])
    }
    
    func adjustFollowing(_ addFollowing: Bool) {
        if addFollowing {
            _following = _following + 1
        } else {
            _following = _following - 1
        }
        
        DataService.ds.REF_CURRENT_USER.child("user-info").updateChildValues(["followingCt": following])
    }
}
