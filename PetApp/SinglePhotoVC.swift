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
            cell.tapActionMore = { (cell) in
                print("POST \(post.postKey)")
                FeedVC.postKeyToPass = post.postKey
                if FeedVC.postKeyToPass != nil{
                    self.moreTapped(postKey: FeedVC.postKeyToPass)
                }
            }
            
                return cell
            } else {
            return SinglePhotoCell()
        }
    }
    
    func moreTapped(postKey: String) {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        //                        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
        //                            print("Edit btn tapped")
        //                        })
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            print("Delete btn tapped")
            let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Delete Post", style: .destructive, handler: { (action) -> Void in
                print("Delete presssed")
                DataService.ds.REF_POSTS.child(postKey).removeValue()
                print("Post removed")
                self.performSegue(withIdentifier: "FeedVC", sender: nil)
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
        //                        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
