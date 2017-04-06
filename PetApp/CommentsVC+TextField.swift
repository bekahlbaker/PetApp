//
//  CommentsVC+TextField.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/24/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
// swiftlint:disable force_cast

import UIKit
import Firebase
import SwiftKeychainWrapper

extension CommentsVC {
    func registerForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func keyboardWillBeShown(notification: NSNotification) {
        self.keyBoardActive = true
        if let info = notification.userInfo {
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.bottomContraint.constant = keyboardFrame.size.height + 16
                self.bottomViewConstraint.constant = keyboardFrame.size.height + 16
            })
        }
    }
    func keyboardWillBeHidden(notification: NSNotification) {
        self.keyBoardActive = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.bottomContraint.constant = self.originalBottomConstraint
            self.bottomViewConstraint.constant = self.originalBottomViewConstraint
        })
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.commentTextField = textField
        if self.keyBoardActive == true {
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        } else if self.keyBoardActive == false {
             NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.keyBoardActive = false
        textField.resignFirstResponder()
        return true
    }
}
