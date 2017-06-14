//
//  FeedCell+Comments.swift
//  PetApp
//
//  Created by Rebekah Baker on 6/13/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper

extension FeedCell {
    func downloadComments() {
        DataService.ds.REF_POSTS.child(self.post.postKey).child("comments").observe(.value, with: { (snapshot) in
            self.clearCmtsText()
            self.comments = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                var i = 1
                for snap in snapshot {
                    print("VALUE OF I : \(i)")
                    if let postDict = snap.value as? [String: AnyObject] {
                        if let username = postDict["username"] as? String {
                            switch i {
                            case 1:
                                self.cmtUsernameLbl1.text = username
                            case 2:
                                self.cmtUsernameLbl2.text = username
                            case 3:
                                self.cmtUsernameLbl3.text = username
                            case 4:
                                self.cmtUsernameLbl4.text = username
                            default:
                                break
                            }
                        }
                        if let comment = postDict["comment"] as? String {
                            switch i {
                            case 1:
                                self.cmtLbl1.text = comment
                            case 2:
                                self.cmtLbl2.text = comment
                            case 3:
                                self.cmtLbl3.text = comment
                            case 4:
                                self.cmtLbl4.text = comment
                            default:
                                break
                            }
                        }
                            self.viewCommentsBtn.setTitle("View all \(snapshot.count) comments", for: .normal)
                    }
                    i += 1
                }
            } else {
                self.viewCommentsBtn.setTitle("Leave a comment", for: .normal)
            }
        })
    }
    func clearCmtsText() {
        self.cmtUsernameLbl1.text = ""
        self.cmtLbl1.text = ""
        self.cmtUsernameLbl2.text = ""
        self.cmtLbl2.text = ""
        self.cmtUsernameLbl3.text = ""
        self.cmtLbl3.text = ""
        self.cmtUsernameLbl4.text = ""
        self.cmtLbl4.text = ""
    }
}
