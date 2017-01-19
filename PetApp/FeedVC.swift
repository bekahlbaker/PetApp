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
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    static var usernameToPass: String!
    static var postKeyToPass: String!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: "Lobster1.4", size: 30) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        self.navigationController!.view.backgroundColor = Color.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name:NSNotification.Name(rawValue: "refreshMyTableView"), object: nil)
        
        downloadData(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadData(tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            ViewUserVC.usernamePassed = FeedVC.usernameToPass
        }
    }
}
