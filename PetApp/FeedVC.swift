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
    var postKeys = [String]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var indexToPass: Int!
    static var usernameToPass: String!
    static var postKeyToPass: String!
    
    var refreshControl: UIRefreshControl!
    var indexPassed = 0
    var isFromSP = false
    var oldIndexPath: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name:NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
//        
//        loadData(tableView)
    }
    
    func loadTableData(_ sender:AnyObject) {
        print("4. LOAD \(self.posts.count)")
        if self.posts.count > 0 {
            print("5. TRUE")
            self.tableView.reloadData()
        }
    }
    
    func refreshList(notification: NSNotification){
        self.loadData(tableView)
    }
    
    func loadData(_ sender:AnyObject) {
        DataService.ds.REF_CURRENT_USER.child("wall").observeSingleEvent(of: .value, with: { (snapshot) in
            self.posts = []
            self.postKeys = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dictionary = snap.value as? [String: Any] {
                        let post = dictionary["post"] as! String
                        self.postKeys.append(post)
                        print("1. POST KEYS \(self.postKeys)")
                    } else {
                        print("Not following any users")
                    }
                }
            }
            for i in 0..<self.postKeys.count {
                print("2. ARRAY \(i)")
                DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: self.postKeys[i]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let post = Post(postKey: self.postKeys[i], postData: postDict)
                                self.posts.insert(post, at: 0)
                                print("3. POSTS \(self.posts.count)")
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

    func refresh(_ sender:AnyObject) {
        self.perform(#selector(loadData(_:)), with: nil, afterDelay: 0.5)
        self.refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       loadData(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = self.posts[indexPath.row]
        print(post)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.delegate = self
            cell.configureCell(post)
            print("Configuring cell")
             FeedVC.postKeyToPass = post.postKey
            
            let userKey = post.userKey
            
            if FeedVC.imageCache.object(forKey: userKey as NSString) != nil {
                cell.profileImg.image = FeedVC.imageCache.object(forKey: userKey as NSString)
                print("using cached profile image")
                
                if FeedCell.isConfigured == true {

                    cell.tapActionUsername = { (cell) in
                        print("POST \(post.userKey)")
                        FeedVC.usernameToPass = post.userKey
                        if FeedVC.usernameToPass != nil {
                            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            ViewUserVC.usernamePassed = FeedVC.usernameToPass
        }
    }
}
