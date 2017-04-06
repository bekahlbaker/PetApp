//
//  DataService.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()
class DataService {
    static let ds = DataService()
    //DB References
    fileprivate var _REF_BASE = DB_BASE
    fileprivate var _REF_POSTS = DB_BASE.child("posts")
    fileprivate var _REF_USERS = DB_BASE.child("users")
    fileprivate var _REF_ACTIVE_USERS = DB_BASE.child("active-users")
    fileprivate var _REF_USER_LIST = DB_BASE.child("user-list")
    //Storage References
    fileprivate var _REF_POST_IMGS = STORAGE_BASE.child("post-imgs")
    fileprivate var _REF_USER_PROFILE = STORAGE_BASE.child("profile_pics")
    fileprivate var _REF_USER_COVER = STORAGE_BASE.child("cover_pics")
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    var REF_ACTIVE_USERS: FIRDatabaseReference {
        return _REF_ACTIVE_USERS
    }
    var REF_USER_LIST: FIRDatabaseReference {
        return _REF_USER_LIST
    }
    var REF_POST_IMGS: FIRStorageReference {
        return _REF_POST_IMGS
    }
    var REF_USER_PROFILE: FIRStorageReference {
        return _REF_USER_PROFILE
    }
    var REF_USER_COVER: FIRStorageReference {
        return _REF_USER_COVER
    }
    var REF_CURRENT_USER: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    func createFirebaseDBUser(_ uid: String, userData: [String: String]) {
        REF_USERS.child(uid).child("user-personal").updateChildValues(userData)
    }
//    func firebaseAuthenticate(_ credential: FIRAuthCredential) {
//        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
//            if error != nil {
//                print("Unable to authenticate with Firebase - \(error)")
//            } else {
//                print("Successfully autheticated with FIrebase")
//                if let user = user {
//                    let userData = ["provider": credential.provider]
//                    self.completeSignIn(user.uid, userData: userData)
//                }
//            }
//        })
//    }
    func completeSignIn(_ id: String, userData: [String: String]) {
        DataService.ds.createFirebaseDBUser(id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
    }
}
