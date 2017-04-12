//
//  ViewUserVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/30/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ViewUserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationBarDelegate {
    @IBOutlet weak var username: UINavigationItem!
    @IBOutlet weak var profileImg: CircleImage!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var ageAndBreedLbl: UILabel!
    @IBOutlet weak var parentsNameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var user: User!
    var isFollowing: Bool!
    static var postKeyToPass: String!
    let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
    var userKeyPassed: String!
    var posts = [Post]()
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    @IBAction func moreBtnTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.global().async {
            if self.userKeyPassed != self.userKey {
                self.followTapped()
            } else {
               self.moreTapped()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
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
    }
    override func viewWillAppear(_ animated: Bool) {
        downloadViewUserContent()
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
    func downloadCollectionViewData() {
        DataService.ds.REF_POSTS.queryOrdered(byChild: "userKey").queryEqual(toValue: self.userKeyPassed).observeSingleEvent(of: .value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.insert(post, at: 0)
                    }
                }
            }
            if self.posts.count > 0 {
                self.collectionView.reloadData()
                self.postsLbl.text = String(self.posts.count)
            }
        })
    }
}
