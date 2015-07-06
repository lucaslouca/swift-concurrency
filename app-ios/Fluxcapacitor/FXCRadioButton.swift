//
//  FXCRadioButton.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 05/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@IBDesignable class FXCRadioButton: FXCButton {  
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if(newValue){
                self.backgroundColor = selectedColor
            } else {
                self.backgroundColor = UIColor.clearColor()
            }
            super.selected = newValue
        }
    }
    
    @IBInspectable var selectedColor: UIColor = UIColor.clearColor()

}
