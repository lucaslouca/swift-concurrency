//
//  FXCViewNavigationSubBar.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 31/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

enum FXCBorderOrientation {
    case Top, Right, Bottom, Left
}

@IBDesignable class FXCBorderView: UIView {
    var topBorder: UIView?
    var rightBorder: UIView?
    var bottomBorder: UIView?
    var leftBorder: UIView?
    var constW: NSLayoutConstraint?
    
    // Top
    @IBInspectable var topBorderColor: UIColor = UIColor.clearColor() {
        didSet {
            applyBorder(.Top)
        }
    }
    
    @IBInspectable var topBorderWidth: CGFloat = 0 {
        didSet {
            applyBorder(.Top)
        }
    }
    
    // Right
    @IBInspectable var rightBorderColor: UIColor = UIColor.clearColor() {
        didSet {
            applyBorder(.Right)
        }
    }
    
    @IBInspectable var rightBorderWidth: CGFloat = 0 {
        didSet {
            applyBorder(.Right)
        }
    }
    
    // Bottom
    @IBInspectable var bottomBorderColor: UIColor = UIColor.clearColor() {
        didSet {
            applyBorder(.Bottom)
        }
    }
    
    @IBInspectable var bottomBorderWidth: CGFloat = 0 {
        didSet {
            applyBorder(.Bottom)
        }
    }
    
    // Left
    @IBInspectable var leftBorderColor: UIColor = UIColor.clearColor() {
        didSet {
            applyBorder(.Left)
        }
    }
    
    @IBInspectable var leftBorderWidth: CGFloat = 0 {
        didSet {
            applyBorder(.Left)
        }
    }
    
    private func applyBorder(orientation: FXCBorderOrientation) {
        switch (orientation) {
        case .Top:
            if (topBorder == nil) {
                topBorder = UIView()
                topBorder!.backgroundColor = self.topBorderColor
                topBorder!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
                self.addSubview(topBorder!)
            }
            topBorder!.frame = CGRectMake(0.0, 0.0, self.frame.size.width, topBorderWidth)
        case .Right:
            if (rightBorder == nil) {
                rightBorder = UIView()
                rightBorder!.backgroundColor = self.rightBorderColor
                rightBorder!.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(rightBorder!)
                
                let constX = NSLayoutConstraint(item: rightBorder!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
                self.addConstraint(constX)
                
                let constY = NSLayoutConstraint(item: rightBorder!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                self.addConstraint(constY)
                
                constW = NSLayoutConstraint(item: rightBorder!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: rightBorderWidth)
                rightBorder!.addConstraint(constW!)
                
                let constH = NSLayoutConstraint(item: rightBorder!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: self.frame.size.height)
                rightBorder!.addConstraint(constH)
            }
            
            constW?.constant = rightBorderWidth
            //            rightBorder!.frame = CGRectMake(self.frame.size.width - rightBorderWidth, 0.0, rightBorderWidth, self.frame.size.height)
            
        case .Bottom:
            if (bottomBorder == nil) {
                bottomBorder = UIView()
                bottomBorder!.backgroundColor = self.bottomBorderColor
                bottomBorder!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
                self.addSubview(bottomBorder!)
            }
            bottomBorder?.frame = CGRectMake(0.0, self.frame.size.height - bottomBorderWidth, self.frame.size.width, bottomBorderWidth)
            
        case .Left:
            if (leftBorder == nil) {
                leftBorder = UIView()
                leftBorder!.backgroundColor = self.leftBorderColor
                leftBorder!.autoresizingMask = UIViewAutoresizing.FlexibleHeight
                self.addSubview(leftBorder!)
            }
            leftBorder!.frame = CGRectMake(0.0, 0.0, leftBorderWidth, self.frame.size.height)
        }
    }
}
