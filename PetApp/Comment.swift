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
    
    private var _comment: String!
    private var _username: String!
    private var _postKey: String!
    
    var comment: String {
        return _comment
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(comment: String, username: String) {
        self._comment = comment
        self._username = username
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let comment = postData["comment"] as? String {
            self._comment = comment
        }
        
        if let username = postData["username"] as? String {
            self._username = username
        }
    }
}
