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
    var usernamePassed: String!
    var isFromFeedVC: Bool!
    static var post: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Photo"
    }
    override func viewDidAppear(_ animated: Bool) {
        downloadData(tableView)
    }
    func downloadData(_ sender: AnyObject) {
        DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: SinglePhotoVC.post).observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.insert(post, at: 0)
                        if self.posts.count > 0 {
                            self.perform(#selector(self.loadTableData(_:)), with: nil, afterDelay: 0.5)
                        }
                    }
                }
            }
        })
    }
    func loadTableData(_ sender: AnyObject) {
        if self.posts.count > 0 {
            self.tableView.reloadData()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePhotoCell") as? SinglePhotoCell {
            cell.profileImg.image = UIImage(named: "user-sm")
            cell.delegate = self
            cell.configureCell(post)
            let userKey = post.userKey
            if FeedVC.imageCache.object(forKey: userKey as NSString) != nil {
                cell.profileImg.image = FeedVC.imageCache.object(forKey: userKey as NSString)
                cell.tapActionUsername = { (cell) in
//                    ViewUserVC.usernamePassed = post.userKey
//                    if ViewUserVC.usernamePassed != nil {
//                        self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
//                    }
                }
//                FeedVC.postKeyToPass = post.postKey
                return cell
            } else {
                let userKey = post.userKey
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
                return cell
            }
        } else {
            return SinglePhotoCell()
        }
    }
}
