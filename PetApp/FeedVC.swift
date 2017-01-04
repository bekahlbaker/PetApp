//
//  FeedVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Kingfisher

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var postsObserved = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var indexToPass: Int!
    static var usernameToPass: String!
    static var postKeyToPass: String!
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeedVC.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.postsObserved = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.postsObserved.insert(post, at: 0)
                    }
                }
            }
        })
        
        refresh(sender: self)
    }

    func refresh(sender:AnyObject) {
        // Code to refresh table view
        DataService.ds.REF_POSTS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.insert(post, at: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
        refreshControl.endRefreshing()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        let postsObserved = self.postsObserved[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.configureCell(post: postsObserved)
            cell.profileImg.image = UIImage(named: "blank-profile-picture")
            
            let userKey = postsObserved.userKey
            if FeedVC.imageCache.object(forKey: userKey as NSString) != nil {
                cell.profileImg.image = FeedVC.imageCache.object(forKey: userKey as NSString)
                print("using cached profile image")
                
                cell.tapAction = { (cell) in
                    print(tableView.indexPath(for: cell)!.row)
                    self.indexToPass = tableView.indexPath(for: cell)!.row
                    if self.indexToPass != nil {
                        self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
                    }
                }
                
                cell.tapActionUsername = { (cell) in
                    print("POST \(post.userKey)")
                    FeedVC.usernameToPass = post.userKey
                    if FeedVC.usernameToPass != nil {
                        self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                    }
                }
                
                cell.tapActionComment = { (cell) in
                    print("POST \(post.postKey)")
                    FeedVC.postKeyToPass = post.postKey
                    if FeedVC.postKeyToPass != nil {
                        self.performSegue(withIdentifier: "CommentsVC", sender: nil)
                    }
                }
                
                return cell
            } else {
                let userKey = post.userKey
                DataService.ds.REF_USERS.child(userKey).child("user-info").observeSingleEvent(of: .value, with:  { (snapshot) in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePhotoVC" {
            let myVC = segue.destination as! SinglePhotoVC
            myVC.indexPassed = self.indexToPass
        }
    }
}
