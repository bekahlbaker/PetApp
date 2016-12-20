//
//  CommentTableView+CommentsVC.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/19/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit

extension CommentsVC {
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        
//        return posts.count
        
    }
    
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
                return UITableViewCell()
        
//        let post = posts[indexPath.row]
//        
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
//            
//            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString), let profileImg = FeedVC.imageCache.object(forKey: post.profileImgUrl as NSString) {
//                print("Getting images from cache")
//                cell.configureCell(post: post, img: img, profileImg: profileImg)
//                
//                cell.tapAction = { (cell) in
//                    print(tableView.indexPath(for: cell)!.row)
//                    self.indexToPass = tableView.indexPath(for: cell)!.row
//                    self.performSegue(withIdentifier: "SinglePhotoVC", sender: nil)
//                }
//                
//                cell.tapActionUsername = { (cell) in
//                    print("POST \(post.username)")
//                    FeedVC.usernameToPass = post.username
//                    self.performSegue(withIdentifier: "ViewUserVC", sender: nil)
//                }
//                
//                cell.tapActionComment = { (cell) in
//                    print("POST \(post.postKeyForPassing)")
//                    FeedVC.postKeyToPass = post.postKeyForPassing
//                    self.performSegue(withIdentifier: "CommentsVC", sender: nil)
//                }
//                
//                return cell
//            } else {
//                cell.configureCell(post: post)
//                return cell
//            }
//            
//        } else {
//            return FeedCell()
//        }
    }
}
