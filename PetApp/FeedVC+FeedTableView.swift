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
    func refreshList(notification: NSNotification) {
        downloadData { (successDownloadingData) in
            if successDownloadingData {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            } else {
                print("Unable to download data, try again")
            }
        }
    }
    func downloadData(completionHandler:@escaping (Bool) -> Void) {
        DispatchQueue.global().async {
//            let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
//            connectedRef.observe(.value, with: { snapshot in
//                if let connected = snapshot.value as? Bool, connected {
//                    print("Connected")
                    DataService.ds.REF_CURRENT_USER.child("wall").observeSingleEvent(of: .value, with: { (snapshot) in
                        self.posts = []
                        self.postKeys = []
                        if let _ = snapshot.value as? NSNull {
                            print("Is not following anyone")
                        } else {
                            print(snapshot)
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
                                        if let postDict = snap.value as? [String: AnyObject] {
                                            let post = Post(postKey: self.postKeys[i], postData: postDict)
                                            self.posts.insert(post, at: 0)
                                            if self.posts.count > 0 {
                                                completionHandler(true)
                                                if let userKey = postDict["userKey"] as? String {
                                                    self.userKeyArray.insert(userKey, at: 0)
                                                }
                                                if let postKey = postDict["postKey"] as? String {
                                                    self.postKeysArray.insert(postKey, at: 0)
                                                }
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    })
//                } else {
//                    print("Not connected")
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noInternetConnectionError"), object: nil)
//                }
//            })
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.profileImg.image = UIImage(named: "user-sm")
            cell.delegate = self
            let post = self.posts[indexPath.row]
            cell.configureCell(post)
                    cell.usernameBtn.tag = indexPath.row
                    cell.viewCommentsBtn.tag = indexPath.row
                    cell.usernameBtn.addTarget(self, action: #selector(self.usernameBtnTapped(sender:)), for: UIControlEvents.touchUpInside)
                    cell.viewCommentsBtn.addTarget(self, action: #selector(self.commentBtnTapped(sender:)), for: UIControlEvents.touchUpInside)
                    let user = cell.usernameBtn.tag
                    let userKey = self.userKeyArray[user]
                    if FeedVC.imageCache.object(forKey: userKey as NSString) != nil {
                        cell.profileImg.image = FeedVC.imageCache.object(forKey: userKey as NSString)
                    } else {
                        cell.usernameBtn.tag = indexPath.row
                        let user = cell.usernameBtn.tag
                        let userKey = self.userKeyArray[user]
                        DataService.ds.REF_USERS.child(userKey).child("user-info").observe( .value, with: { (snapshot) in
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
                    }
            return cell
        } else {
            return FeedCell()
        }
    }
    func usernameBtnTapped(sender: UIButton) {
        let userKey = sender.tag
        self.userKeyToPass = self.userKeyArray[userKey]
        performSegue(withIdentifier: "ViewUserVC", sender: nil)
    }
    func commentBtnTapped(sender: UIButton) {
        let postKey = sender.tag
        self.postKeyToPass = self.postKeysArray[postKey]
        print(self.postKeyToPass)
        performSegue(withIdentifier: "CommentsVC", sender: nil)
    }
}
