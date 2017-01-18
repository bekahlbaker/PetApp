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
//    static var indexPassed: Int!
    var usernamePassed: String!
    var isFromFeedVC: Bool!
    static var post: String!
    
//    @IBAction func backBtn(_ sender: Any) {
//        if isFromFeedVC == true {
//            performSegue(withIdentifier: "FeedVC", sender: nil)
//        } else if isFromFeedVC == false {
//            performSegue(withIdentifier: "ViewUserVC", sender: nil)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("SPVC: \(SinglePhotoVC.indexPassed)")
        print(SinglePhotoVC.post)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Photo"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        downloadData(tableView)
    }
    
    func downloadData(_ sender:AnyObject) {
        DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: SinglePhotoVC.post).observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.insert(post, at: 0)
                        print("1. POSTS \(self.posts.count)")
                        if self.posts.count > 0 {
                            self.perform(#selector(self.loadTableData(_:)), with: nil, afterDelay: 0.5)
                        }
                    }
                }
            }
        })
    }
    
    func loadTableData(_ sender:AnyObject) {
        print("2. LOAD \(self.posts.count)")
        if self.posts.count > 0 {
            print("3. TRUE")
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
            cell.delegate = self
                cell.configureCell(post)
            
                cell.tapActionUsername = { (cell) in
                        print("POST \(post.userKey)")
                        self.usernamePassed = post.userKey
                        if self.usernamePassed != nil {
                            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                        }
                    }
                    FeedVC.postKeyToPass = post.postKey
                
            return cell
            } else {
            return SinglePhotoCell()
        }
    }
}
