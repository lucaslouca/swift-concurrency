//
//  FXCIconRadius.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 03/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCIconLocation: UIView {

    @IBInspectable var color: UIColor = FXCDrawUtil.iconColor
    
    @IBInspectable var scale: CGFloat = 6
    
    override func drawRect(rect: CGRect) {
        let iconLayer = FXCDrawUtil.iconLocationLayer(x:0, y:0, scale:scale/10.0, color:color)
        self.layer.addSublayer(iconLayer)
    }

}
