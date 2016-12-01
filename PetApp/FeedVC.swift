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
    
     var activeRow = 0


    @IBAction func usernameTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "ViewUserVC", sender: nil)
        
//        let myVC = storyboard?.instantiateViewController(withIdentifier: "ViewUserVC") as! ViewUserVC
//        myVC.usernamePassed = FeedCell.usernameToPass
//        navigationController?.pushViewController(myVC, animated: true)
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
//                    print("SNAP: \(snap)")
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

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
//
//            cell.configureCell()
//            return cell
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            let myVC = segue.destination as! ViewUserVC
            myVC.usernamePassed = FeedCell.usernameToPass
            print(myVC.usernamePassed)
        }
    }
    
}
