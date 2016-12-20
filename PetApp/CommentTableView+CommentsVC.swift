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
        
        return comments.count
        
    }
    
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let comment = comments[indexPath.row]
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
            
            cell.configureCell(postKey: self.postKeyPassed, comment: comment)
            return cell
            
        } else {
            return CommentCell()
        }
    }
}
