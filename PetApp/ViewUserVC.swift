//
//  ViewUserVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 11/30/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class ViewUserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
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
    
    var usernamePassed: String!
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernamePassed = FeedVC.usernameToPass
        print("VUVC \(self.usernamePassed!)")
        
        DataService.ds.REF_POSTS.queryOrdered(byChild: "userKey").queryEqual(toValue: self.usernamePassed!).observeSingleEvent(of: .value, with: { (snapshot) in
            
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
        
        //download user info & image
        DataService.ds.REF_USERS.child("\(self.usernamePassed!)").child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        
                        if let username = dictionary["username"] as? String {
                            self.username.title = username
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
        
//        let followBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ViewUserVC.followBtnMethod))
//        navigationItem.rightBarButtonItem = followBtn
//        title = "Follow"
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let post = posts[indexPath.row]
    
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPicCell", for: indexPath) as? UserPicCell {
            if let img = UserVC.userImageCache.object(forKey: post.imageURL as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
    
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
    
    }
    
    @IBOutlet weak var followBtn: UIBarButtonItem!
    
    @IBAction func followBtnTapped(_ sender: AnyObject) {
       let followingBtn = UIBarButtonItem(title: "Following", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = followingBtn
    }
    
//    func followBtnMethod() {
//        title = "Following"
//    }

}
