//
//  CustomTextInput.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit

// simple class to prevent the caret from showing up
class CustomTextField: UITextField {

    override func caretRectForPosition(position: UITextPosition!) -> CGRect {

        return CGRectZero
    }
}