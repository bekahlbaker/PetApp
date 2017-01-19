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

class CurrentUserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationBarDelegate {
    
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var username: UINavigationItem!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var ageAndBreedLbl: UILabel!
    @IBOutlet weak var parentsNameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func moreBtnTapped(_ sender: Any) {
        self.moreTapped()
    }
 
    var posts = [Post]()
    static var userImageCache: NSCache<NSString, UIImage> = NSCache()
    static var postKeyToPass: String!
    var indexToPass: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController!.view.backgroundColor = Color.white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        downloadCollectionViewData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        downloadUserInfo()
    }
    
    func downloadCollectionViewData() {
        DataService.ds.REF_CURRENT_USER.child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    self.username.title = currentUser
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
                        self.postsLbl.text = String(self.posts.count)
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
        let delete = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
            let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                try! FIRAuth.auth()?.signOut()
                self.performSegue(withIdentifier: "EntryVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            }
            alert.addAction(deletePost)
            alert.addAction(cancel)
            
            self.show(alert, sender: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
