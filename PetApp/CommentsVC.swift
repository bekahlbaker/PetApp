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

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!

    var commentKey: String!
    var comments = [Comment]()
    static var postKeyPassed: String!
    var currentUsername: String!
    var keyBoardActive = false
    var originalBottomConstraint: CGFloat!
    var originalBottomViewConstraint: CGFloat!
    @IBAction func commentBtnTapped(_ sender: AnyObject) {
        if self.commentTextField.text != "" {
            postToFirebase()
            commentTextField.text = ""
            commentTextField.resignFirstResponder()
        } else {
            let alert = UIAlertController(title: "Please enter a comment", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var commentTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTextField.delegate = self
        self.originalBottomConstraint = self.bottomContraint.constant
        self.originalBottomViewConstraint = self.bottomViewConstraint.constant
        self.commentTextField.returnKeyType = UIReturnKeyType.done
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
        let comment: [String: Any] = [
            "comment": self.commentTextField.text! as String,
            "username": self.currentUsername as String,
            "userKey": KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        ]
        let firebasePost = DataService.ds.REF_POSTS.child(CommentsVC.postKeyPassed)
        firebasePost.child("comments").childByAutoId().setValue(comment)
        NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "adjustCommentCountTrue"), object: nil)
    }
    func alert(sender: UIBarButtonItem) {
        if self.commentTextField.text != "" {
            let alert = UIAlertController(title: "", message: "If you cancel now, your comment will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
            let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { (_) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            }
            alert.addAction(discard)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
}
