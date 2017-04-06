//  RespinsiveTextField.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/12/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//
//
//  ResponsiveTextFieldViewController.swift
//  Swift version of: VBResponsiveTextFieldViewController
//  Original code: www.github.com/ttippin84/VBResponsiveTextFieldViewController
//
//  Created by David Sandor on 9/27/14.
//  Copyright (c) 2014 David Sandor. All rights reserved.
//
//  swiftlint:disable force_cast

import Foundation
import UIKit

class ResponsiveTextFieldViewController: UIViewController {
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBAction func swipeDetected(_ sender: Any) {
        if swipeGesture.direction == UISwipeGestureRecognizerDirection.down {
            NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    weak var activeTextField: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ResponsiveTextFieldViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ResponsiveTextFieldViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        for subview in self.view.subviews {
            if subview.isKind(of: UITextField.self) {
                let textField = subview as! UITextField
                textField.addTarget(self, action: #selector(ResponsiveTextFieldViewController.textFieldDidReturn(_:)), for: UIControlEvents.editingDidEndOnExit)
                textField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func keyboardWillShow(_ notification: NSNotification) {
        self.keyboardIsShowing = true
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.arrangeViewOffsetFromKeyboard()
        }
    }
    func keyboardWillHide(_ notification: NSNotification) {
        self.keyboardIsShowing = false
        self.returnViewToInitialFrame()
    }
    func arrangeViewOffsetFromKeyboard() {
        let theApp: UIApplication = UIApplication.shared
        let windowView: UIView? = theApp.delegate!.window!
        let textFieldLowerPoint: CGPoint = CGPoint(x:self.activeTextField!.frame.origin.x, y:self.activeTextField!.frame.origin.y + self.activeTextField!.frame.size.height)
        let convertedTextFieldLowerPoint: CGPoint = self.view.convert(textFieldLowerPoint, to: windowView)
        let targetTextFieldLowerPoint: CGPoint = CGPoint(x:self.activeTextField!.frame.origin.x, y:self.keyboardFrame.origin.y)
        let targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
        let adjustedViewFrameCenter: CGPoint = CGPoint(x:self.view.center.x, y:self.view.center.y + targetPointOffset - 16.0)
        UIView.animate(withDuration: 0.1, animations: {
            self.view.center = adjustedViewFrameCenter
        })
    }
    func returnViewToInitialFrame() {
        let initialViewRect: CGRect = CGRect(x:0.0, y:0.0, width:self.view.frame.size.width, height:self.view.frame.size.height + 32.0)
        if !initialViewRect.equalTo(self.view.frame) {
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame = initialViewRect
            })
        }
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if (self.activeTextField != nil) {
//            self.activeTextField?.resignFirstResponder()
//            self.activeTextField = nil
//        }
//    }
//    
    func textFieldDidReturn(_ textField: UITextField!) {
        textField.resignFirstResponder()
        self.activeTextField = nil
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        if self.keyboardIsShowing {
            self.arrangeViewOffsetFromKeyboard()
        }
    }
}
