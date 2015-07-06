//
//  FXCIconPriceDollar.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 06/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCIconPriceDollar: UIView {

    @IBInspectable var scale: CGFloat = 8
    
    @IBInspectable var color: UIColor = FXCDrawUtil.iconColor
    
    override func drawRect(rect: CGRect) {
        let iconLayer = FXCDrawUtil.iconIconPriceDollar(x:0, y:0, scale:scale/10.0, color:color)
        self.layer.addSublayer(iconLayer)
    }

}
