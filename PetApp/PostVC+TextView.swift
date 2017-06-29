//
//  PostVC+TextView.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/2/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//
// swiftlint:disable force_cast

import UIKit

extension PostVC {
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
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//change constraint
                self.topConstraint.constant = -keyboardFrame.size.height + 50
            })
        }
    }
    func keyboardWillBeHidden(notification: NSNotification) {
        self.keyBoardActive = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
//change constraint
            self.topConstraint.constant = self.originalTopConstraint
        })
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.keyBoardActive = false
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.captionTextView = textView
        if self.keyBoardActive == true {
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        } else if self.keyBoardActive == false {
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.captionTextView = textView
        if self.keyBoardActive == true {
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        } else if self.keyBoardActive == false {
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        if textView.text.isEmpty {
            textView.text = "Write a caption..."
            textView.textColor = UIColor.lightGray
            self.characterCount.text = "140"
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCount()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        updateCharacterCount()
        let maxCharacter: Int = 140
        return textView.text.characters.count +  (text.characters.count - range.length) <= maxCharacter
    }
    func updateCharacterCount() {
       self.characterCount.text = String(140 - self.captionTextView.text.characters.count)
    }
}
