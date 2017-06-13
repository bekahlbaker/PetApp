//
//  FeedCell+FeedCommentCell.swift
//  PetApp
//
//  Created by Rebekah Baker on 6/7/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper

extension FeedCell {
    func downloadComments() {
        DataService.ds.REF_POSTS.child(post.postKey).child("comments").observe(.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("No comments")
            } else {
                self.commentArray = []
                self.usernameArray = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    // self.comments.text = String(snapshot.count)
                    for snap in snapshot {
                        if let postDict = snap.value as? [String: AnyObject] {
                            let username = postDict["username"] as? String
                            let comment = postDict["comment"] as? String
                            self.commentArray.append(comment!)
                            self.usernameArray.append(username!)
                        }
                    }
                }
            }
            self.commentTableView.reloadData()
        })
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = commentTableView.dequeueReusableCell(withIdentifier: "FeedCommentCell")
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FeedCommentCell")
        return cell!
    }
}
