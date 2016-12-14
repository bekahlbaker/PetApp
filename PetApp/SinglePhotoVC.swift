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
    
    @IBAction func usernameTapped(_ sender: AnyObject) {
        if FeedCell.usernameToPass != nil {
            performSegue(withIdentifier: "ViewUserVC", sender: nil)
        } else {
            print("NIL")
        }
    }
    
    @IBAction func commentTapped(_ sender: AnyObject) {
        if self.postKeyPassed != nil {
            performSegue(withIdentifier: "CommentsVC", sender: nil)
        } else {
            print("NIL")
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    var postKeyPassed: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Single Photo VC: \(self.postKeyPassed)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: postKeyPassed).observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let post = Post(postKey: self.postKeyPassed, postData: postDict)
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
    

//    func likeTapped(sender: UITapGestureRecognizer) {
//        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeBtn.image = UIImage(named: "empty-heart")
////                self.adjustLikes(addLike: true)
//                self.likesRef.setValue(true)
//            } else {
//                self.likeBtn.image = UIImage(named: "filled-heart")
////                self.adjustLikes(addLike: false)
//                self.likesRef.removeValue()
//            }
//        })
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePhotoCell") as? SinglePhotoCell {
                cell.configureCell(post: post)
                return cell
            } else {
            return SinglePhotoCell()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            let myVC = segue.destination as! ViewUserVC
            myVC.usernamePassed = FeedCell.usernameToPass
        }
//        if segue.identifier == "CommentsVC" {
//            let myVC = segue.destination as! CommentsVC
//            myVC.postKeyPassed = self.postKeyPassed
//        }
    }
    
}
