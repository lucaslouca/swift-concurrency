//
//  FXCRadioButtonGroupView.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 05/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCRadioButtonGroupView: UIView {
    let buttonController: FXCRadioButtonGroup = FXCRadioButtonGroup()
    
    override func didMoveToSuperview() {
        for view in self.subviews as [UIView] {
            if let radioButton = view as? FXCRadioButton {
                buttonController.addButton(radioButton)
            }
        }
    }
}
