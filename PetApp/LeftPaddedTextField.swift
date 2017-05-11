//
//  LeftPaddedTextField.swift
//  PetApp
//
//  Created by Rebekah Baker on 5/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

import UIKit

class LeftPaddedTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 8, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 8, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
}
