//
//  ViewUserVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/30/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//
// swiftlint:disable force_cast

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
    @IBOutlet weak var paging: UIImageView!
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followingBtn: UIButton!
    @IBAction func followingBtnTapped(_ sender: UIButton) {
        print(followingBtn.tag)
        performSegue(withIdentifier: "FollowListVC", sender: followingBtn.tag)
    }
    @IBOutlet weak var followersBtn: UIButton!
    @IBAction func followersBtnTapped(_ sender: UIButton) {
        print(followersBtn.tag)
        performSegue(withIdentifier: "FollowListVC", sender: followersBtn.tag)
    }
    var user: User!
    var isFollowing: Bool!
    static var postKeyToPass: String!
    var userKeyToPass: String!
    let currentUserKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
    var userKeyPassed: String!
    var isCurrentUser: Bool!
    var posts = [Post]()
    var pageNumber = 1
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
        let moreBtn = UIBarButtonItem(image: UIImage(named:"more-dots"), style: .plain, target: self, action: #selector(moreBtnTapped))
        self.navigationItem.rightBarButtonItem = moreBtn
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        showPageOne()
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        print(self.currentUserKey)
//        print(self.userKeyPassed)
//        if self.userKeyPassed == nil {
//            self.isCurrentUser = true
//            self.userKeyPassed = self.currentUserKey
//            self.userKeyToPass = self.userKeyPassed
//            downloadViewUserContent()
//        } else {
//            self.isCurrentUser = false
//            self.userKeyToPass = self.currentUserKey
//            downloadViewUserContent()
//        }
//        print(self.isCurrentUser)
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(self.currentUserKey)
        print(self.userKeyPassed)
        if self.userKeyPassed == nil {
            self.isCurrentUser = true
//            self.userKeyPassed = self.currentUserKey
            self.userKeyToPass = self.userKeyPassed
            downloadViewUserContent()
        } else {
            self.isCurrentUser = false
            self.userKeyToPass = self.currentUserKey
            downloadViewUserContent()
        }
        print(self.isCurrentUser)
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
        if self.userKeyPassed != nil {
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
        } else {
            DataService.ds.REF_POSTS.queryOrdered(byChild: "userKey").queryEqual(toValue: self.currentUserKey).observeSingleEvent(of: .value, with: { (snapshot) in
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FollowListVC" {
            if let myVC = segue.destination as? FollowListVC {
                myVC.userKeyPassed = self.userKeyToPass
                myVC.btnTagPassed = sender as! Int!
                myVC.isCurrentUser = self.isCurrentUser
            }
        }
    }
    func moreBtnTapped() {
        if self.isCurrentUser == false {
            self.followTapped()
        } else if self.isCurrentUser == true {
            self.moreTapped()
        }
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                if pageNumber == 2 {
                    showPageOne()
                }
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                if pageNumber == 1 {
                    showPageTwo()
                }
            default:
                break
            }
        }
    }
    func showPageOne() {
        pageNumber = 1
        fullNameLbl.isHidden = false
        bioLbl.isHidden = false
        parentsNameLbl.isHidden = true
        ageAndBreedLbl.isHidden = true
        locationLbl.isHidden = true
        paging.image = UIImage(named: "page1")
    }
    func showPageTwo() {
        pageNumber = 2
        fullNameLbl.isHidden = true
        bioLbl.isHidden = true
        parentsNameLbl.isHidden = false
        ageAndBreedLbl.isHidden = false
        locationLbl.isHidden = false
        paging.image = UIImage(named: "page2")
    }
}
