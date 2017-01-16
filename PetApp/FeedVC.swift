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
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
    }
    
    func loadData(_ sender:AnyObject) {
        
        DataService.ds.REF_CURRENT_USER.child("wall").observe(.value, with: { (snapshot) in
            
            self.postKeys = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dictionary = snap.value as? [String: Any] {
                        let post = dictionary["post"] as! String
                        print("FOLLOWING \(post)")
                        self.postKeys.append(post)
                        print(self.postKeys)
                    } else {
                        print("Not following any users")
                    }
                }
            }
            for i in 0..<self.postKeys.count {
                DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: self.postKeys[i]).observe(.value, with: { (snapshot) in
                    
                self.postsObserved = []
                    
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let post = Post(postKey: self.postKeys[i], postData: postDict)
                                self.postsObserved.insert(post, at: 0)
                            }
                        }
                    }
                })
            }
            
        })
        self.refresh(self)
    }

    func refresh(_ sender:AnyObject) {
        DataService.ds.REF_CURRENT_USER.child("wall").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.postKeys = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let dictionary = snap.value as? [String: Any] {
                        let post = dictionary["post"] as! String
                        print("FOLLOWING \(post)")
                        self.postKeys.append(post)
                        print(self.postKeys)
                    } else {
                        print("Not following any users")
                    }
                }
            }
            for i in 0..<self.postKeys.count {
                DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: self.postKeys[i]).observe(.value, with: { (snapshot) in
                    
                    //                    self.postsObserved = []
                    
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let post = Post(postKey: self.postKeys[i], postData: postDict)
                                self.posts.insert(post, at: 0)
                            }
                        }
                    }
                    if self.posts.count > 0 {
                        self.tableView.reloadData()
                    }
                })
            }
            
        })


        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsObserved.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        let postsObserved = self.postsObserved[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.configureCell(postsObserved)
             FeedVC.postKeyToPass = post.postKey
//            cell.profileImg.image = UIImage(named: "blank-profile-picture")
            
            let userKey = postsObserved.userKey
            let captionView = cell.caption
            let save = cell.saveBtn
            
            if FeedVC.imageCache.object(forKey: userKey as NSString) != nil {
                cell.profileImg.image = FeedVC.imageCache.object(forKey: userKey as NSString)
                print("using cached profile image")
                
                if FeedCell.isConfigured == true {
//                    cell.tapAction = { (cell) in
//                        print("POST \(post.postKey)")
//                        FeedVC.postKeyToPass = post.postKey
//                        print(tableView.indexPath(for: cell)!.row)
//                        self.indexToPass = tableView.indexPath(for: cell)!.row
//                        if self.indexToPass != nil {
//                            self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
//                        }
//                    }
                    
                    cell.tapActionUsername = { (cell) in
                        print("POST \(post.userKey)")
                        FeedVC.usernameToPass = post.userKey
                        if FeedVC.usernameToPass != nil {
                            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                        }
                    }
//                    
//                    cell.tapActionComment = { (cell) in
//                        print("POST \(post.postKey)")
//                        FeedVC.postKeyToPass = post.postKey
//                        if FeedVC.postKeyToPass != nil {
//                            self.performSegue(withIdentifier: "CommentsVC", sender: nil)
//                        }
//                    }
                    
                    cell.tapActionMore = { (cell) in
                        print("POST \(post.postKey)")
                        FeedVC.postKeyToPass = post.postKey
                        if FeedVC.postKeyToPass != nil{
                            self.moreTapped(FeedVC.postKeyToPass, caption: captionView!, saveBtn: save!)
                        }
                    }
                    
                    cell.tapActionSave = { (cell) in
                        print("Save btn tapped")
                        self.saveEditedCaption(post.postKey, caption: captionView!)
                        captionView?.isEditable = false
                        save?.isHidden = true
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
        if segue.identifier == "SinglePhotoVC" {
            SinglePhotoVC.indexPassed = self.indexToPass
            SinglePhotoVC.post = FeedVC.postKeyToPass
           let myVC = segue.destination as! SinglePhotoVC
            myVC.isFromFeedVC = true
        }
        if segue.identifier == "ViewUserVC" {
            ViewUserVC.usernamePassed = FeedVC.usernameToPass
        }
    }
    
    @IBAction func viewUserTapped(_ sender: Any) {
        let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        print("USER KEY \(userKey)")
        FeedVC.usernameToPass = userKey
        if FeedVC.usernameToPass != nil {
            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
        }
    }
    
    func moreTapped(_ postKey: String, caption: UITextView, saveBtn: UIButton) {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            print("Edit btn tapped")
            caption.isEditable = true
            saveBtn.isHidden = false
            caption.becomeFirstResponder()
        })
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            print("Delete btn tapped")
            let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Delete Post", style: .destructive, handler: { (action) -> Void in
                print("Delete presssed")
                DataService.ds.REF_POSTS.child(postKey).removeValue()
                print("Post removed")
                self.refresh(self.tableView)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel Button Pressed")
            }
            
            alert.addAction(deletePost)
            alert.addAction(cancel)
            
            self.show(alert, sender: nil)
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel
            , handler: { (action) -> Void in
                print("Cancel btn tapped")
        })
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveEditedCaption(_ postKey: String, caption: UITextView) {
        DataService.ds.REF_POSTS.child(postKey).updateChildValues(["caption": "\(caption.text!)"])
        self.refresh(self.tableView)
    }
}
