//
//  Comment.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/20/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    fileprivate var _comment: String!
    fileprivate var _username: String!
    fileprivate var _postKey: String!
    fileprivate var _userKey: String!
    fileprivate var _commentCount: Int!
    
    var comment: String {
        return _comment
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    var userKey: String {
        return _userKey
    }
    
    var commentCount: Int {
        return _commentCount
    }
    
    init(comment: String, username: String, userKey: String, commentCount: Int) {
        self._comment = comment
        self._username = username
        self._userKey = userKey
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let comment = postData["comment"] as? String {
            self._comment = comment
        }
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        if let userKey = postData["userKey"] as? String {
            self._userKey = userKey
        }
    }
    
    func adjustCommentCount(_ addComment: Bool, postKey: String) {
        if addComment {
            _commentCount = _commentCount + 1
        } else {
            _commentCount = _commentCount - 1
        }
        
        DataService.ds.REF_POSTS.child(postKey).updateChildValues(["commentCount": commentCount])
    }
}
