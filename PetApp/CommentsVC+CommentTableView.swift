//
//  CommentsVC+CommentTableView.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

extension CommentsVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
            cell.configureCell(self.postKeyPassed, comment: comment)
            
            DataService.ds.REF_USERS.child(comment.userKey).child("user-info").observe( .value, with:  { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    if let profileURL = dictionary["profileImgUrl"] as? String {
                        let ref = FIRStorage.storage().reference(forURL: profileURL)
                        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                print("Unable to Download profile image from Firebase storage.")
                            } else {
                                if let imgData = data {
                                    if let profileImg = UIImage(data: imgData) {
                                        cell.profileImg.image = profileImg
                                    }
                                }
                            }
                            
                        })
                    }
                }
            })
            return cell
            
        } else {
            return CommentCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)! as UITableViewCell
        let cellValue = comments[currentCell.tag]
        ViewUserVC.usernamePassed = cellValue.userKey
        if ViewUserVC.usernamePassed != nil {
            performSegue(withIdentifier: "ViewUserVC", sender: nil)
        }
    }
    
    func getUsername() {
        DataService.ds.REF_CURRENT_USER.child("user-info").observe(.value, with:  { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.currentUsername = currentUser as String!
                }
            }
        })
    }
    
    func downloadCommentData() {
        if FeedVC.postKeyToPass != nil {
            self.postKeyPassed = FeedVC.postKeyToPass
            self.getCommentCount()
            DataService.ds.REF_POSTS.child(self.postKeyPassed).child("comments").observe(.value, with: { (snapshot) in
                self.comments = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let comment = Comment(postKey: key, postData: postDict)
                            self.comments.append(comment)
                        }
                    }
                }
                if self.comments.count > 0 {
                    self.tableView.reloadData()
                }
            })
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func getCommentCount() {
        DataService.ds.REF_POSTS.child(self.postKeyPassed).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentCount = dictionary["commentCount"] as? Int {
                    self.commentCount = currentCount + 1
                }
            }
        })
    }
}
