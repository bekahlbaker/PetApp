//
//  CommentsVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/12/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: ResponsiveTextFieldViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var comments = [Comment]()
    var postKeyPassed: String!
    var commentCount = 0
    var currentUsername: String!

    func alert(sender: UIBarButtonItem) {
            if self.commentTextField.text != "" {
                let alert = UIAlertController(title: "", message: "If you cancel now, your comment will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
                let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) -> Void in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    print("Cancel Button Pressed")
                }
                
                alert.addAction(discard)
                alert.addAction(cancel)
                
                self.navigationController?.present(alert, animated: true, completion: nil)
            } else {
                 _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func commentBtnTapped(_ sender: AnyObject) {
        if self.commentTextField.text != "" {
            postToFirebase()
            commentTextField.text = ""
            print("Added comment to Post")
            commentTextField.resignFirstResponder()
            self.getCommentCount()
        } else {
            let alert = UIAlertController(title: "Please enter a comment", message: "", preferredStyle: UIAlertControllerStyle.alert);
            let ok = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var commentTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(alert(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FeedVC.postKeyToPass != nil {
            self.postKeyPassed = FeedVC.postKeyToPass
            print("COMMENTS VC: \(self.postKeyPassed)")
            
            self.getCommentCount()
            
            DataService.ds.REF_POSTS.child(self.postKeyPassed).child("comments").observe(.value, with: { (snapshot) in
                
                self.comments = []
                
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let comment = Comment(postKey: key, postData: postDict)
                            self.comments.append(comment)
                        }
                    }
                }
                if self.comments.count > 0 {
                    self.tableView.reloadData()
                }
                
            })
        } else {
            print("No post key")
        }
        
        DataService.ds.REF_CURRENT_USER.child("user-info").observe(.value, with:  { (snapshot) in
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
    

    func getCommentCount() {
        DataService.ds.REF_POSTS.child(self.postKeyPassed).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentCount = dictionary["commentCount"] as? Int {
                print("DOWNLOADED COUNT \(currentCount)")
                self.commentCount = currentCount + 1
                print(self.commentCount)
                }
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
