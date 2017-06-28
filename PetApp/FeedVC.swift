//
//  FeedVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/4/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Kingfisher

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var postKeys = [String]()
    var userKeyArray = [String]()
    var postKeysArray = [String]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var userKeyToPass: String!
    var postKeyToPass: String!
    var refreshControl: UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.checkIfHasFilledOutProfileOnce { (hasFilledOutProfile) in
//            if !hasFilledOutProfile {
////                DataService.ds.REF_CURRENT_USER.child("user-personal").updateChildValues(["HasFilledOutProfileOnce": true])
//                self.performSegue(withIdentifier: "toProfileVC", sender: nil)
//            }
//        }
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
//        imageView.contentMode = .scaleAspectFit
//        let image = UIImage(named: "PetsPic")
//        imageView.image = image
//        navigationItem.titleView = imageView
//        self.navigationController!.view.backgroundColor = Color.white
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList(notification:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name:NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noInternetConnectionError(notification:)), name:NSNotification.Name(rawValue: "noInternetConnectionError"), object: nil)
    }
    func noInternetConnectionError(notification: NSNotification) {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_: UIAlertAction) in
            self.refreshControl.endRefreshing()
//handle no internet connection
        }))
        self.present(alert, animated: true, completion: nil)
    }
//    func checkIfHasFilledOutProfileOnce(completionHandler:@escaping (Bool) -> Void) {
//        DataService.ds.REF_CURRENT_USER.child("user-personal").child("HasFilledOutProfileOnce").observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                print("FIRST time viewing profile")
//                completionHandler(false)
//            } else {
//                print("NOT first time viewing profile")
//                completionHandler(true)
//            }
//        })
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            if let myVC = segue.destination as? ViewUserVC {
                myVC.userKeyPassed = self.userKeyToPass
            }
        }
        if segue.identifier == "CommentsVC" {
            if let myVC = segue.destination as? CommentsVC {
             myVC.postKeyPassed = self.postKeyToPass
            }
        }
    }
}
