//
//  CommentsVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/12/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var comments = [Post]()
    var postKeyPassed: String!
    var commentCount = 0
    var currentUsername: String!
    
    @IBAction func backBtnTapped(_ sender: AnyObject) {
        if self.commentTextField.text == "" {
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        } else {
            let alert = UIAlertController(title: "", message: "If you cancel now, your comment will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
            let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) -> Void in
                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel Button Pressed")
            }
            
            alert.addAction(discard)
            alert.addAction(cancel)
            
            show(alert, sender: nil)
        }
    }
    
    @IBAction func commentBtnTapped(_ sender: AnyObject) {
        if self.commentTextField.text != "" {
            self.commentCount += 1
            postToFirebase()
            commentTextField.text = ""
            print("Added comment to Post")
            commentTextField.resignFirstResponder()
        } else {
            let alert = UIAlertController(title: "Please enter a comment", message: "", preferredStyle: UIAlertControllerStyle.alert);
            let ok = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(ok)
            show(alert, sender: self)
        }
    }
    
    @IBOutlet weak var commentTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postKeyPassed = FeedVC.postKeyToPass
        print("COMMENTS VC: \(self.postKeyPassed)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.child(self.postKeyPassed).child("comments").observe(.value, with: { (snapshot) in
        
            self.comments = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                print("SNAPSHOT DOWNLOADED \(snapshot)")
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.comments.insert(post, at: 0)
                    }
                }
            }
            self.tableView.reloadData()
            
        })
        
        DataService.ds.REF_CURRENT_USER.observe( .value, with:  { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    print("BEKAH: \(currentUser)")
                    self.currentUsername = currentUser as String!
                }
            }
        })
    }
    
    func postToFirebase() {
        
        let comment: Dictionary<String, Any> = [
            "comment": self.commentTextField.text! as String,
            "username" : self.currentUsername as String
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.child(self.postKeyPassed)
        firebasePost.updateChildValues(["commentCount": self.commentCount])
        firebasePost.child("comments").childByAutoId().setValue(comment)
        
        
    }
    
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
