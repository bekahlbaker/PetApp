//
//  User.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/14/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//
// swiftlint:disable shorthand_operator

import Foundation
import UIKit
import Firebase

class User {
    fileprivate var _userKey: String!
    fileprivate var _username: String!
    fileprivate var _name: String!
    fileprivate var _parentsName: String!
    fileprivate var _species: String!
    fileprivate var _breed: String!
    fileprivate var _location: String!
    fileprivate var _about: String!
    var userKey: String {
        return _userKey
    }
    var username: String {
        return _username ?? ""
    }
    var name: String {
        return _name ?? ""
    }
    var parentsName: String {
        return _parentsName ?? ""
    }
    var species: String {
        return _species ?? ""
    }
    var breed: String {
        return _breed ?? ""
    }
    var location: String {
        return _location ?? ""
    }
    var about: String {
        return _about ?? ""
    }
    init(username: String, name: String, parentsName: String, species: String, breed: String, location: String, about: String) {
        self._username = username
        self._name = name
        self._parentsName = parentsName
        self._species = species
        self._breed = breed
        self._location = location
        self._about = about
    }
    init(userKey: String, userData: [String: AnyObject]) {
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
    }
}
