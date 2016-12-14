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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func usernameTapped(_ sender: AnyObject) {
        if FeedCell.usernameToPass != nil {
            performSegue(withIdentifier: "ViewUserVC", sender: nil)
        } else {
            print("NIL")
        }
    }
    
    @IBAction func imageTapped(_ sender: AnyObject) {
        if FeedCell.postKeyToPass != nil {
            print("FEED VC: \(FeedCell.postKeyToPass)")
            performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
        } else {
            print("NIL")
        }
    }
    
    @IBAction func commentTapped(_ sender: AnyObject) {
//        let key = DataService.ds.REF_POSTS.queryOrderedByKey()
//            print("FEED VC: \(key)")
        performSegue(withIdentifier: "CommentsVC", sender: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {

            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString), let profileImg = FeedVC.imageCache.object(forKey: post.profileImgUrl as NSString) {
                print("Getting images from cache")
                cell.configureCell(post: post, img: img, profileImg: profileImg)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        
        } else {
            return FeedCell()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            let myVC = segue.destination as! ViewUserVC
            myVC.usernamePassed = FeedCell.usernameToPass
        }
        if segue.identifier == "SinglePhotoVC" {
            let myVC = segue.destination as! SinglePhotoVC
            myVC.postKeyPassed = FeedCell.postKeyToPass
        }
//        if segue.identifier == "CommentsVC" {
//            let myVC = segue.destination as! CommentsVC
//            myVC.postKeyPassed = FeedCell.postKeyToPass
//        }
    }
    
}
