//
//  FeedTableView+FeedVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/19/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

extension FeedVC {
    func refreshList(notification: NSNotification){
        refresh(self)
    }
    
    func downloadData(_ sender:AnyObject) {
        DataService.ds.REF_CURRENT_USER.child("wall").observeSingleEvent(of: .value, with: { (snapshot) in
            self.posts = []
            self.postKeys = []
            
            if let _ = snapshot.value as? NSNull {
                print("Is not following anyone")
            } else {
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        self.postKeys.append(snap.key)
                    }
                }
            }
            for i in 0..<self.postKeys.count {
                DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: self.postKeys[i]).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let post = Post(postKey: self.postKeys[i], postData: postDict)
                                self.posts.insert(post, at: 0)
                                if self.posts.count > 0 {
                                    self.perform(#selector(self.loadTableData(_:)), with: nil, afterDelay: 0.5)
                                }
                            }
                        }
                    }
                })
            }
        })
    }
    
    func loadTableData(_ sender:AnyObject) {
        if self.posts.count > 0 {
            self.tableView.reloadData()
        }
    }
    
    func refresh(_ sender:AnyObject) {
        self.perform(#selector(downloadData(_:)), with: nil, afterDelay: 0.5)
        self.refreshControl.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.delegate = self
            cell.configureCell(post)
            FeedVC.postKeyToPass = post.postKey
            let userKey = post.userKey
            if FeedVC.imageCache.object(forKey: userKey as NSString) != nil {
                cell.profileImg.image = FeedVC.imageCache.object(forKey: userKey as NSString)
                
                if FeedCell.isConfigured == true {
                    cell.tapActionUsername = { (cell) in
                        FeedVC.usernameToPass = post.userKey
                        if FeedVC.usernameToPass != nil {
                            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                        }
                    }
                    cell.tapActionComments = { (cell) in
                        FeedVC.postKeyToPass = post.postKey
                        print(FeedVC.postKeyToPass)
                        if FeedVC.postKeyToPass != nil {
                            self.performSegue(withIdentifier: "CommentsVC", sender: nil)
                        }
                    }
                }
                return cell
            } else {
                let userKey = post.userKey
                DataService.ds.REF_USERS.child(userKey).child("user-info").observe( .value, with:  { (snapshot) in
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
                                            FeedVC.imageCache.setObject(profileImg, forKey: userKey as NSString)
                                        }
                                    }
                                }
                            })
                        }
                    }
                })
                return cell
            }
        } else {
            return FeedCell()
        }
    }
}
