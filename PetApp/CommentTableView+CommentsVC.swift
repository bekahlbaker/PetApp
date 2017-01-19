//
//  CommentTableView+CommentsVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

extension CommentsVC {
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
        
    }
    
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
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
                                print("Profile image downloaded from FB Storage.")
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
        print(cellValue.userKey)
        ViewUserVC.usernamePassed = cellValue.userKey
        performSegue(withIdentifier: "ViewUserVC", sender: nil)
    }
}
