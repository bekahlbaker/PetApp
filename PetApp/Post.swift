//
//  Post.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/17/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postKeyForPassing: String!
    private var _username: String!
    private var _profileImgUrl: String!
    private var _caption: String!
    private var _imageURL: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postKeyForPassing: String {
        return _postKey
    }
    
    var username: String {
        return _username
    }
    
    var profileImgUrl: String {
        return _profileImgUrl
    }
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(postKeyForPassing: String, username: String, profileImgUrl: String, caption: String, imageURL: String, likes: Int) {
        self._postKeyForPassing = postKeyForPassing
        self._username = username
        self._profileImgUrl = profileImgUrl
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let postKeyForPassing = postData["postKey"] as? String {
            self._postKeyForPassing = postKeyForPassing
        }
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        if let profileImgUrl = postData["profileImgUrl"] as? String {
            self._profileImgUrl = profileImgUrl
        }
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.updateChildValues(["likes": likes])
    }
}
