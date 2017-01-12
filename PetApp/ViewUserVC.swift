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
    
    var isFollowing: Bool!
    static var postKeyToPass: String!
    var indexToPass: Int!
    let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
    
    @IBOutlet weak var homeBtn: UIBarButtonItem!
   
    @IBAction func homeBtnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "FeedVC", sender: nil)
    }
    
    @IBAction func moreBtnTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.global().async {
            if ViewUserVC.usernamePassed == self.userKey {
                print("This is the current user")
                self.moreTapped()
            } else {
                self.followTapped()
            }
        }

    }

    static var usernamePassed: String!
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ViewUserVC.usernamePassed)
        
        checkIfFollowing()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.white
        navigationBar.delegate = self;
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Title"
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    
        edgesForExtendedLayout = []

        DispatchQueue.global().async {
        let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
        if ViewUserVC.usernamePassed == userKey {
            print("This is the current user")
            DispatchQueue.main.async {
                if ProfileVC.profileCache.object(forKey: "profileImg") != nil {
                    self.profileImg.image = ProfileVC.profileCache.object(forKey: "profileImg")
                    print("using cached profile img on ViewUser")
                }
                if ProfileVC.coverCache.object(forKey: "coverImg") != nil {
                    self.coverImg.image = ProfileVC.coverCache.object(forKey: "coverImg")
                    print("using cached cover img")
                }

            }
        } else {
            self.homeBtn.isEnabled = false
            self.homeBtn.tintColor = UIColor.clear
            }
        }
        
        DataService.ds.REF_POSTS.queryOrdered(byChild: "userKey").queryEqual(toValue: ViewUserVC.usernamePassed).observeSingleEvent(of: .value, with: { (snapshot) in
            
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
            if self.posts.count > 0 {
                self.collectionView.reloadData()
                self.postsLbl.text = String(self.posts.count)
            }
        })
        
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
        
            let userKey = ViewUserVC.usernamePassed
            //download user info & image
            DataService.ds.REF_USERS.child(userKey!).child("user-info").observe(.value, with: { (snapshot) in
                print("snapshot")
                print(snapshot)
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    if let username = dictionary["username"] as? String {
                        self.navigationItem.title = username
                    }
                    
                    if let name = dictionary["full-name"] as? String {
                        self.fullNameLbl.text = name
                    }
                    
                    if let breed = dictionary["breed"] as? String {
                        if let age = dictionary["age"] as? String {
                            if age != "" {
                                self.ageAndBreedLbl.text = "\(age)"
                                if breed != "" {
                                    self.ageAndBreedLbl.text = "\(age) \(breed)"
                                } else {
                                    if let species = dictionary["species"] as? String {
                                        if species != "" {
                                            self.ageAndBreedLbl.text = "\(age) \(species)"
                                        }
                                    }
                                }
                            } else {
                                if breed != "" {
                                    self.ageAndBreedLbl.text = "\(breed)"
                                } else {
                                    if let species = dictionary["species"] as? String {
                                        if species != "" {
                                            self.ageAndBreedLbl.text = "\(species)"
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    if let parent = dictionary["parents-name"] as? String {
                        if parent != "" {
                            self.parentsNameLbl.text = "Parent: \(parent)"
                        }
                    }
                    
                    if let location = dictionary["location"] as? String {
                        self.locationLbl.text = location
                    }
                    
                    if let about = dictionary["about"] as? String {
                        self.bioLbl.text = about
                    }
                    
                    if let following = dictionary["followingCt"] as? Int {
                        print("following \(following)")
                        self.followingLbl.text = "\(following)"
                    }

                    
                    //download profile img
                    if let url = dictionary["profileImgUrl"] as? String {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: url)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let profileImg = UIImage(data: data!)
                                self.profileImg.image = profileImg
                                print("Using firebase image for profile")
                            }
                        }
                    }
                    //download cover photo
                    if let url = dictionary["coverImgUrl"] as? String {
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: url)
                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print("Unable to download image from firebase")
                            } else {
                                let coverImg = UIImage(data: data!)
                                self.coverImg.image = coverImg
                                print("Using firebase image for cover")
                            }
                        }
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
        if let cell = collectionView.cellForItem(at: indexPath) {
            if UserPicCell.isConfigured == true {
                ViewUserVC.postKeyToPass = post.postKey
                self.indexToPass = collectionView.indexPath(for: cell)!.item
                print(self.indexToPass)
                if self.indexToPass != nil {
                    self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePhotoVC" {
            let myVC = segue.destination as! SinglePhotoVC
            myVC.indexPassed = self.indexToPass
            myVC.usernamePassed = ViewUserVC.usernamePassed
            myVC.isFromFeedVC = false
            myVC.post = ViewUserVC.postKeyToPass
        }
    }
    
    func checkIfFollowing() {
        DataService.ds.REF_CURRENT_USER.child("following").child(ViewUserVC.usernamePassed).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.isFollowing = false
                print("Not following")
            } else {
                self.isFollowing = true
                print("Following")
                print("USER KEYS \(snapshot.key)")
            }
        })
    }

    func followTapped() {
        let alert = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        if isFollowing == false {
            let follow = UIAlertAction(title: "Follow", style: .default, handler: { (action) -> Void in
                print("Follow btn tapped")
                DataService.ds.REF_CURRENT_USER.child("following").updateChildValues(["\(ViewUserVC.usernamePassed!)": true])
                self.adjustFollowing(true)
                self.checkIfFollowing()
                DataService.ds.REF_USERS.child("\(ViewUserVC.usernamePassed!)").child("followers").childByAutoId().updateChildValues(["user": "\(self.userKey)"])
                //            self.adjustFollowers(true)
                
            })
            alert.addAction(follow)
        } else if isFollowing == true {
            let follow = UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) -> Void in
                print("Unfollow btn tapped")
                DataService.ds.REF_CURRENT_USER.child("following").removeValue()
                self.adjustFollowing(false)
                self.checkIfFollowing()
                DataService.ds.REF_USERS.child("\(ViewUserVC.usernamePassed!)").child("followers").removeValue()
                //            self.adjustFollowers(true)
                
            })
            alert.addAction(follow)
        }
        let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func adjustFollowing(_ addFollowing: Bool) {
        DataService.ds.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                var following = dictionary["followingCt"] as? Int
                print(following!)
                if addFollowing {
                    following = following! + 1
                } else {
                    following = following! - 1
                }
                DataService.ds.REF_CURRENT_USER.updateChildValues(["followingCt": following as Any])
            }
        })
    }
    
    func moreTapped() {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            print("Edit btn tapped")
            DispatchQueue.main.async {
                let userKey = KeychainWrapper.standard.string(forKey: KEY_UID)! as String
                if ViewUserVC.usernamePassed == userKey {
                    self.performSegue(withIdentifier: "ProfileVC", sender: nil)
                }
            }

        })
        let delete = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
            print("Log Out btn tapped")
            let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let deletePost = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
                print("Log Out presssed")
                KeychainWrapper.standard.removeObject(forKey: KEY_UID)
                print("User removed")
                try! FIRAuth.auth()?.signOut()
                self.performSegue(withIdentifier: "EntryVC", sender: nil)
            })
            let  cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel Button Pressed")
            }
            
            alert.addAction(deletePost)
            alert.addAction(cancel)
            
            self.show(alert, sender: nil)
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel
            , handler: { (action) -> Void in
                print("Cancel btn tapped")
        })
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
