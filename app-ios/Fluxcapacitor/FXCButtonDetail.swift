//
//  FXCButtonDetail.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 03/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCButtonDetail: FXCButton {

    override func drawRect(rect: CGRect) {
        let width: CGFloat = 8.0, y: CGFloat = 6.0
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        CGContextSetStrokeColorWithColor(context, FXCDrawUtil.iconCGColor)
        CGContextMoveToPoint(context, rect.width/2 - width/2, y)
        CGContextAddLineToPoint(context, rect.width/2 + width/2, rect.height/2)
        CGContextAddLineToPoint(context, rect.width/2 - width/2, rect.height - y)
        CGContextStrokePath(context)
    }
 

}
