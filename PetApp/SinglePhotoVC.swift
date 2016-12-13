//
//  SinglePhotoVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/8/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit
import Firebase

class SinglePhotoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedUsername: String!
    
    @IBAction func usernameTapped(_ sender: AnyObject) {
        if FeedCell.usernameToPass != nil {
            print(FeedCell.usernameToPass)
            performSegue(withIdentifier: "ViewUserVC", sender: nil)
        } else {
            print("NIL")
        }
    }
    
    @IBAction func commentTapped(_ sender: AnyObject) {
        if FeedCell.postKeyToPass != nil {
            print("FEED VC: \(FeedCell.postKeyToPass)")
            performSegue(withIdentifier: "CommentsVC", sender: nil)
        } else {
            print("NIL")
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    var postKeyPassed: String!
//    var likesRef: FIRDatabaseReference!
//    var post: Post!
//    
//    @IBOutlet weak var profileImg: CircleImage!
//    @IBOutlet weak var usernameLbl: UIButton!
//    @IBOutlet weak var likeBtn: UIImageView!
//    @IBOutlet weak var likesImgSm: UIImageView!
//    @IBOutlet weak var captionTxtView: UITextView!
//    @IBOutlet weak var likesLbl: UILabel!
//    @IBOutlet weak var imageView: UIImageView!
//    
//    @IBAction func likeBtnTapped(_ sender: AnyObject) {
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Single Photo VC: \(self.postKeyPassed)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print(snap)
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                        let key = self.postKeyPassed
                        let post = Post(postKey: self.postKeyPassed, postData: postDict)
                        self.posts.insert(post, at: 0)
                        print("POST: \(post)")
                    }
                }
            }
            self.tableView.reloadData()
        })
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
//        tap.numberOfTapsRequired = 1
//        likeBtn.addGestureRecognizer(tap)
//        likeBtn.isUserInteractionEnabled = true
//        
//        print("Single Photo VC: \(postKeyPassed)")
//        
//        likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(postKeyPassed)
//        
//        if postKeyPassed != "" {
//            DataService.ds.REF_POSTS.child(postKeyPassed).observeSingleEvent(of: .value, with: { (snapshot) in
//                if let dictionary = snapshot.value as? [String: Any] {
//                    
//                    if let username = dictionary["username"] as? String {
//                        self.usernameLbl.setTitle(username, for: .normal)   
//                    }
//                    
//                    if let caption = dictionary["caption"] as? String {
//                        self.captionTxtView.text = caption
//                    }
//                    
//                    if let likes = dictionary["likes"] as? Int {
//                        self.likesLbl.text = String(likes)
//                    }
//                    
//                    guard let imgURL = dictionary["imageURL"] as? String else {
//                        print("No image to download")
//                        return
//                    }
//                    
//                    //download img
//                    if imgURL == (dictionary["imageURL"] as? String)! {
//                        let storage = FIRStorage.storage()
//                        let storageRef = storage.reference(forURL: imgURL)
//                        storageRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) in
//                            if error != nil {
//                                print("Unable to download image from firebase")
//                            } else {
//                                let img = UIImage(data: data!)
//                                self.imageView.image = img
//                            }
//                        }
//                    }
//                    
//                    guard let profileImgUrl = dictionary["profileImgUrl"] as? String else {
//                        print("No profile image to download")
//                        return
//                    }
//                    
//                    //download profile img
//                    if profileImgUrl == (dictionary["profileImgUrl"] as? String)! {
//                        let ref = FIRStorage.storage().reference(forURL: profileImgUrl)
//                        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                            if error != nil {
//                                print("Unable to Download profile image from Firebase storage.")
//                            } else {
//                                print("Image downloaded from FB Storage.")
//                                if let imgData = data {
//                                    if let profileImg = UIImage(data: imgData) {
//                                        self.profileImg.image = profileImg
//                                        FeedVC.imageCache.setObject(profileImg, forKey: profileImgUrl as NSString)
//                                    }
//                                }
//                            }
//                            
//                        })
//                        
//                    }
//                }
//            })
//
//        } else {
//            print("No post key")
//        }
//        
//        likesRef.observeSingleEvent(of: .value, with:  { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeBtn.image = UIImage(named: "empty-heart")
//            } else {
//                self.likeBtn.image = UIImage(named: "filled-heart")
//                self.likesImgSm.image = UIImage(named: "filled-heart")
//            }
//        })
        
        
    }
    
//    func likeTapped(sender: UITapGestureRecognizer) {
//        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeBtn.image = UIImage(named: "empty-heart")
//                self.adjustLikes(addLike: true)
//                self.likesRef.setValue(true)
//            } else {
//                self.likeBtn.image = UIImage(named: "filled-heart")
//                self.adjustLikes(addLike: false)
//                self.likesRef.removeValue()
//            }
//        })
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePhotoCell") as? SinglePhotoCell {
//            if let img = UserVC.userImageCache.object(forKey: post.imageURL as NSString) {
//                cell.configureCell(post: post, img: img)
//                return cell
//            } else {
                cell.configureCell(post: post)
                return cell
//            }
        } else {
            return SinglePhotoCell()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewUserVC" {
            let myVC = segue.destination as! ViewUserVC
            myVC.usernamePassed = FeedCell.usernameToPass
        }
        if segue.identifier == "CommentsVC" {
            let myVC = segue.destination as! CommentsVC
            myVC.postKeyPassed = FeedCell.postKeyToPass
        }
    }
    
}
