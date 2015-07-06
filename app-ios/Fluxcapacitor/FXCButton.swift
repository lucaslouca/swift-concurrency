//
//  FXCButton.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 17/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            if self.enabled {
                layer.borderColor = borderColor.CGColor
            } else {
                layer.borderColor = CGColorCreateCopyWithAlpha(borderColor.CGColor, 0.2)
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.blackColor() {
        didSet {
            if self.enabled {
                setTitleColor(textColor, forState: UIControlState.Normal)
            } else {
                setTitleColor(UIColor(CGColor: CGColorCreateCopyWithAlpha(textColor.CGColor, 0.2)), forState: UIControlState.Disabled)
            }
        }
    }
    
    
    override var enabled:Bool{
        didSet {
            if self.enabled {
                layer.borderColor = borderColor.CGColor
                setTitleColor(textColor, forState: UIControlState.Normal)
            } else {
                layer.borderColor = CGColorCreateCopyWithAlpha(borderColor.CGColor, 0.2)
                setTitleColor(UIColor(CGColor: CGColorCreateCopyWithAlpha(textColor.CGColor, 0.2)), forState: UIControlState.Disabled)
            }
        }
    }
    
    override var highlighted: Bool {
        get {
            return super.highlighted
            
        }
        set {
            
            if(newValue){
                layer.borderColor = CGColorCreateCopyWithAlpha(borderColor.CGColor, 0.6)
            } else {
                layer.borderColor = borderColor.CGColor
            }
            super.highlighted = newValue
        }
    }

}
