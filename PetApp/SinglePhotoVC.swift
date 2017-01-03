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
    var indexPassed: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SPVC: \(indexPassed)")
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPassed]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePhotoCell") as? SinglePhotoCell {
            cell.configureCell(post: post)
            
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
            return SinglePhotoCell()
        }
    }
    
}
