//
//  SinglePhotoVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class SinglePhotoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var userKeyArray = [String]()
    var postKeysArray = [String]()
    var userKeyToPass: String!
    var postKeyToPass: String!
    var usernamePassed: String!
    static var post: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Photo"
    }
    override func viewDidAppear(_ animated: Bool) {
        downloadData { (successDownloadingData) in
            if successDownloadingData {
                self.tableView.reloadData()
                print("Reload Table")
            } else {
                print("Unable to download data, try again")
            }
        }
    }
    func downloadData(completionHandler:@escaping (Bool) -> Void) {
        DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: SinglePhotoVC.post).observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = 500
        let tHeight = tableView.bounds.height
        return tHeight > minHeight ? tHeight : minHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePhotoCell") as? SinglePhotoCell {
            cell.profileImg.image = UIImage(named: "dog-in-wig")
            cell.delegate = self
            let post = self.posts[indexPath.row]
            cell.configureCell(post, completionHandler: { (success) -> Void in
                if success {
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
//                                            print("Unable to Download profile image from Firebase storage.")
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
                } else {
                    print("Could not configure cell")
                }
            })
            return cell
        } else {
            return SinglePhotoCell()
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
        performSegue(withIdentifier: "CommentsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            if let myVC = segue.destination as? ViewUserVC {
                myVC.userKeyPassed = self.userKeyToPass
            }
        }
        if segue.identifier == "CommentsVC" {
            if let myVC = segue.destination as? CommentsVC {
                myVC.postKeyPassed = self.postKeyToPass
            }
        }
    }
}
