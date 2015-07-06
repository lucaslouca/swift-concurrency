//
//  FXCPriceIcon.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 29/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCIconPrice: UIView {

    @IBInspectable var color: UIColor = FXCDrawUtil.iconColor
    
    override func drawRect(rect: CGRect) {
        let ctx:CGContextRef  = UIGraphicsGetCurrentContext()
        let star = FXCDrawUtil.iconStarPath(x: rect.width/2, y: rect.height/2, radius: rect.height/3, sides: 25, pointyness: 5)
        CGContextAddPath(ctx, star);
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillPath(ctx)
    }
  

}
