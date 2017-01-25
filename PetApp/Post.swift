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

    fileprivate var _username: String!
    fileprivate var _profileImgUrl: String!
    fileprivate var _caption: String!
    fileprivate var _commentCount: Int!
    fileprivate var _imageURL: String!
    fileprivate var _likes: Int!
    fileprivate var _postKey: String!
    fileprivate var _userKey: String!
    fileprivate var _postRef: FIRDatabaseReference!
    
    var username: String {
        return _username
    }
    
    var profileImgUrl: String {
        return _profileImgUrl
    }
    
    var caption: String {
        return _caption
    }
    
    var commentCount: Int {
        return _commentCount
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
    
    var userKey: String {
        return _userKey
    }
    
    init(username: String, userKey: String, profileImgUrl: String, caption: String, commentCount: Int, imageURL: String, likes: Int) {

        self._username = username
        self._userKey = userKey
        self._profileImgUrl = profileImgUrl
        self._caption = caption
        self._commentCount = commentCount
        self._imageURL = imageURL
        self._likes = likes
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        if let userKey = postData["userKey"] as? String {
            self._userKey = userKey
        }
        
        if let profileImgUrl = postData["profileImgUrl"] as? String {
            self._profileImgUrl = profileImgUrl
        }
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let commentCount = postData["commentCount"] as? Int {
            self._commentCount = commentCount
        }
        
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(_ addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.updateChildValues(["likes": likes])
    }
    
    func adjustCommentCount(_ addComment: Bool) {
        if addComment {
            _commentCount = _commentCount + 1
        } else {
            _commentCount = _commentCount - 1
        }
        
        DataService.ds.REF_POSTS.child(_postKey).updateChildValues(["commentCount": commentCount])
    }

}
