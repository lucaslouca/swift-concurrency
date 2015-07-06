//
//  FXCSearchBar.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 31/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCSearchBar: UISearchBar {

    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var searchFieldBackgroundColor: UIColor = UIColor.clearColor() {
        didSet {
            let textField = self.valueForKey("searchField") as! UITextField
            textField.backgroundColor = searchFieldBackgroundColor
        }
    }
    
    @IBInspectable var searchFieldBorderWidth: CGFloat = 0 {
        didSet {
            let textField = self.valueForKey("searchField") as! UITextField
            textField.layer.borderWidth = searchFieldBorderWidth
        }
    }
    
    @IBInspectable var searchFieldBorderColor: UIColor = UIColor.clearColor() {
        didSet {
            let textField = self.valueForKey("searchField") as! UITextField
            textField.layer.borderColor = searchFieldBorderColor.CGColor
        }
    }
}
