//
//  CommentsVC+CommentTableView.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

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
            cell.delegate = self
            cell.configureCell(self.postKeyPassed, comment: comment)
            DataService.ds.REF_USERS.child(comment.userKey).child("user-info").observe( .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    if let profileURL = dictionary["profileImgUrl"] as? String {
                        let ref = FIRStorage.storage().reference(forURL: profileURL)
                        ref.data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
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
        self.userKeyToPass = self.userKeyArray[currentCell.tag]
        performSegue(withIdentifier: "ViewUserVC", sender: nil)
    }
    func getUsername() {
        DataService.ds.REF_CURRENT_USER.child("user-info").observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.currentUsername = currentUser as String!
                }
            }
        })
    }
    func downloadCommentData(completionHandler:@escaping (Bool) -> Void) {
        if self.postKeyPassed != nil {
            DataService.ds.REF_POSTS.child(self.postKeyPassed).child("comments").observe(.value, with: { (snapshot) in
                self.comments = []
                self.commentKeys = []
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? [String: AnyObject] {
                            let key = snap.key
                            self.commentKeys.append(key)
                            let comment = Comment(postKey: key, postData: postDict)
                            self.comments.append(comment)
                            if self.comments.count > 0 {
                                completionHandler(true)
                                if let userKey = postDict["userKey"] as? String {
                                    self.userKeyArray.insert(userKey, at: 0)
                                }
                            }
                        }
                    }
                }
            })
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    func refreshList(notification: NSNotification) {
        downloadCommentData { (successDownloadingData) in
            if successDownloadingData {
                self.tableView.reloadData()
                print("Reload Table")
            } else {
                print("Unable to download data, try again")
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let cell: CommentCell = self.tableView.cellForRow(at: indexPath) as? CommentCell {
            if self.currentUsername == cell.usernameLbl.text {
                return true
            }
        }
        return false
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_) in
            let alert = UIAlertController(title: "Are you sure you want to delete this comment?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let yes = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                //DELETE ITEM AT INDEX PATH
                let commentKey = self.commentKeys[indexPath.row]
                self.deleteComment(commentKey: commentKey, sender: indexPath.row)
            })
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor(red:0.96, green:0.14, blue:0.35, alpha:1.0)
        return [delete]
    }
    func deleteComment(commentKey: String, sender: Int) {
        print("SENDER \(sender)")
        print(self.commentKeys)
        print(self.comments)
        DataService.ds.REF_POSTS.child(self.postKeyPassed).child("comments").child(commentKey).removeValue()
        self.commentKeys.remove(at: sender)
        self.comments.remove(at: sender)
        self.tableView.reloadData()
    }
}
