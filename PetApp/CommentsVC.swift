//
//  CommentsVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/12/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class CommentsVC: ResponsiveTextFieldViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var commentKey: String!
    var comments = [Comment]()
    var postKeyPassed: String!
    var commentCount = 0
    var currentUsername: String!

    @IBAction func commentBtnTapped(_ sender: AnyObject) {
        if self.commentTextField.text != "" {
            postToFirebase()
            commentTextField.text = ""
            commentTextField.resignFirstResponder()
            self.getCommentCount()
        } else {
            let alert = UIAlertController(title: "Please enter a comment", message: nil, preferredStyle: UIAlertControllerStyle.alert);
            let ok = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var commentTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(alert(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name:NSNotification.Name(rawValue: "refreshCommentTableView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteComment), name:NSNotification.Name(rawValue: "deleteComment"), object: nil)
        
        self.title = "Comments"
        
        getUsername()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        downloadCommentData()
    }
    
    func postToFirebase() {
        let comment: Dictionary<String, Any> = [
            "comment": self.commentTextField.text! as String,
            "username" : self.currentUsername as String,
            "userKey": KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        ]
        let firebasePost = DataService.ds.REF_POSTS.child(self.postKeyPassed)
        firebasePost.updateChildValues(["commentCount": self.commentCount])
        firebasePost.child("comments").childByAutoId().setValue(comment)
    }

    func alert(sender: UIBarButtonItem) {
        if self.commentTextField.text != "" {
            let alert = UIAlertController(title: "", message: "If you cancel now, your comment will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
            let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            alert.addAction(discard)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
