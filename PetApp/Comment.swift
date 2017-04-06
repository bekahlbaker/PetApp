//
//  Comment.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/20/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//
// swiftlint:disable shorthand_operator

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
        self._commentCount = commentCount
    }
    init(postKey: String, postData: [String: AnyObject]) {
        self._postKey = postKey
        if let comment = postData["comment"] as? String {
            self._comment = comment
        }
        if let username = postData["username"] as? String {
            self._username = username
        }
        if let postKey = postData["postKey"] as? String {
            self._postKey = postKey
        }
        if let userKey = postData["userKey"] as? String {
            self._userKey = userKey
        }
        if let commentCount = postData["commentCount"] as? Int {
            self._commentCount = commentCount
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
