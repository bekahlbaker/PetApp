////
////  CurrentUserVC.swift
////  PetApp
////
////  Created by Rebekah Baker on 11/11/16.
////  Copyright © 2016 Rebekah Baker. All rights reserved.
////

import UIKit
import Firebase
import Kingfisher
import SwiftKeychainWrapper

class CurrentUserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewUser: UITableView!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func moreBtnTapped(_ sender: UIBarButtonItem) {
        self.moreTapped()
    }
 
    var user: User!
    var posts = [Post]()
    static var userImageCache: NSCache<NSString, UIImage> = NSCache()
    static var postKeyToPass: String!
    var indexToPass: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController!.view.backgroundColor = Color.white
        self.navigationController?.title = "User"
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableViewUser.dataSource = self
        tableViewUser.delegate = self
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshInfo(notification:)), name:NSNotification.Name(rawValue: "refreshCurrentUserVC"), object: nil)
        loadUserInfo(tableViewUser)
        downloadCollectionViewData()
//        setImgsFromCache()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUserInfo(tableViewUser)
    }
    
//    func refreshInfo(notification: NSNotification){
//        setImgsFromCache()
//    }
    
//    func setImgsFromCache() {
//        DispatchQueue.global().async {
//            if ProfileVC.profileCache.object(forKey: "profileImg") != nil {
//                self.profileImg.image = ProfileVC.profileCache.object(forKey: "profileImg")
//                print("Using cached profile img")
//            }
//            if ProfileVC.coverCache.object(forKey: "coverImg") != nil {
//                self.coverImg.image = ProfileVC.coverCache.object(forKey: "coverImg")
//                print("Using cached cover Img")
//            }
//        }
//    }
    
    func downloadCollectionViewData() {
        DataService.ds.REF_CURRENT_USER.child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.navigationController?.title = currentUser
                    DataService.ds.REF_POSTS.queryOrdered(byChild: "username").queryEqual(toValue: currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
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
                        self.collectionView.reloadData()
//                        self.postsLbl.text = String(self.posts.count)
                    })
                }
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPicCell", for: indexPath) as? UserPicCell {
            cell.configureCell(post)
            return cell
        } else {
            return UserPicCell()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        if UserPicCell.isConfigured == true {
            ViewUserVC.postKeyToPass = post.postKey
            SinglePhotoVC.post = post.postKey
            self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
        }
    }
    
    func moreTapped() {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "ProfileVC", sender: nil)
        })
        let logOut = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
            let confirmLogOut = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                try! FIRAuth.auth()?.signOut()
                self.performSegue(withIdentifier: "EntryVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            alert.addAction(confirmLogOut)
            alert.addAction(cancel)
            
            self.navigationController?.present(alert, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        alertController.addAction(edit)
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
}
