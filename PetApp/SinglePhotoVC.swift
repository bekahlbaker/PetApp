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
    static var indexPassed: Int!
    var usernamePassed: String!
    var isFromFeedVC: Bool!
    static var post: String!
    
    @IBAction func backBtn(_ sender: Any) {
        if isFromFeedVC == true {
            performSegue(withIdentifier: "FeedVC", sender: nil)
        } else if isFromFeedVC == false {
            performSegue(withIdentifier: "ViewUserVC", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SPVC: \(SinglePhotoVC.indexPassed)")
        print(SinglePhotoVC.post)
        
        tableView.delegate = self
        tableView.dataSource = self
        
//            if self.isFromFeedVC == true {
//                print("Is from Feed")
                //from FeedVC
                DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: SinglePhotoVC.post).observe(.value, with: { (snapshot) in
                
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
                if self.posts.count > 0 {
                    self.tableView.reloadData()
                }
            })
//            } else if self.isFromFeedVC == false {
//                //from ViewUserVC
//                print("Not from Feed")
//                print(self.usernamePassed)
//                
//                DataService.ds.REF_POSTS.queryOrderedByKey().queryEqual(toValue: self.post).observe(.value, with: { (snapshot) in
//                    
//                self.posts = []
//                
//                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                    for snap in snapshot {
//                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                            let key = snap.key
//                            let post = Post(postKey: key, postData: postDict)
//                            self.posts.insert(post, at: 0)
//                        }
//                    }
//                }
//                if self.posts.count > 0 {
//                    self.tableView.reloadData()
//                }
//            })
//            }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = posts[SinglePhotoVC.indexPassed!]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePhotoCell") as? SinglePhotoCell {
                cell.configureCell(post)
                
                let captionView = cell.caption
                let save = cell.saveBtn
                
                    cell.tapActionUsername = { (cell) in
                        print("POST \(post.userKey)")
                        self.usernamePassed = post.userKey
                        if self.usernamePassed != nil {
                            self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
                        }
                    }
                    
//                    cell.tapActionComment = { (cell) in
//                        print("POST \(post.postKey)")
                        FeedVC.postKeyToPass = post.postKey
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
                
            return cell
            } else {
            return SinglePhotoCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            ViewUserVC.usernamePassed = self.usernamePassed
        }
        if segue.identifier == "FeedVC" {
            let myVC = segue.destination as! FeedVC
            myVC.indexPassed = SinglePhotoVC.indexPassed
            myVC.isFromSP = true
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
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func saveEditedCaption(_ postKey: String, caption: UITextView) {
        DataService.ds.REF_POSTS.child(postKey).updateChildValues(["caption": "\(caption.text!)"])
    }
}
