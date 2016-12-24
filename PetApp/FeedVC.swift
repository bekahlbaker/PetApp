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
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var indexToPass: Int!
    static var usernameToPass: String!
    static var postKeyToPass: String!

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {

            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString), let profileImg = FeedVC.imageCache.object(forKey: post.profileImgUrl as NSString) {
                print("Getting images from cache")
                cell.configureCell(post: post, img: img, profileImg: profileImg)
                
                cell.tapAction = { (cell) in
                    print(tableView.indexPath(for: cell)!.row)
                    self.indexToPass = tableView.indexPath(for: cell)!.row
                    if self.indexToPass != nil {
                        self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
                    }
                }

                cell.tapActionUsername = { (cell) in
                    print("POST \(post.username)")
                    FeedVC.usernameToPass = post.username
                    if FeedVC.usernameToPass != nil {
                        self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                    }
                }
                
                cell.tapActionComment = { (cell) in
                    print("POST \(post.postKeyForPassing)")
                    FeedVC.postKeyToPass = post.postKeyForPassing
                    if FeedVC.postKeyToPass != nil {
                        self.performSegue(withIdentifier: "CommentsVC", sender: nil)
                    }
                }
                
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
        if segue.identifier == "SinglePhotoVC" {
            let myVC = segue.destination as! SinglePhotoVC
            myVC.indexPassed = self.indexToPass
        }
    }
}
