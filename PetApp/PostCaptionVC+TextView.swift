//
//  PostCaptionVC+TextView.swift
//  PetApp
//
//  Created by Rebekah Baker on 12/2/16.
//  Copyright © 2016 Rebekah Baker. All rights reserved.
//

import UIKit

extension PostCaptionVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
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
