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
        
        DataService.ds.REF_CURRENT_USER.child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                if let currentUser = dictionary["username"] as? String {
                    print("BEKAH: \(currentUser)")
                    
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
        DataService.ds.REF_CURRENT_USER.child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
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
                    self.aboutLbl.text = about
                }
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
    
    override func viewDidAppear(_ animated: Bool) {
        DataService.ds.REF_CURRENT_USER.child("user-info").observeSingleEvent(of: .value, with: { (snapshot) in
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
                    self.aboutLbl.text = about
                }
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
                SinglePhotoVC.post = post.postKey
                self.indexToPass = collectionView.indexPath(for: cell)!.item
                print(self.indexToPass)
                SinglePhotoVC.indexPassed = self.indexToPass
                print("Happens after index to pass and post key to pass")
                if self.indexToPass != nil {
                    self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePhotoVC" {
            let myVC = segue.destination as! SinglePhotoVC
            myVC.usernamePassed = ViewUserVC.usernamePassed
            myVC.isFromFeedVC = false
        }
    }
    
    func moreTapped() {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            print("Edit btn tapped")
            self.performSegue(withIdentifier: "ProfileVC", sender: nil)
            
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
