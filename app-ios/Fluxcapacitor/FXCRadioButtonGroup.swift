//
//  FXCRadioButtonGroup.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 05/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCRadioButtonGroup: NSObject {
    var buttonsArray = [UIButton]()
    private weak var currentSelectedButton:UIButton? = nil
    
    init(buttons: UIButton...) {
        super.init()
        for aButton in buttons {
            aButton.addTarget(self, action: "selected:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.buttonsArray = buttons
    }
    
    func addButton(aButton: UIButton) {
        buttonsArray.append(aButton)
        aButton.addTarget(self, action: "selected:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func removeButton(aButton: UIButton) {
        for (index, iteratingButton) in buttonsArray.enumerate() {
            if(iteratingButton == aButton) {
                iteratingButton.removeTarget(self, action: "selected:", forControlEvents: UIControlEvents.TouchUpInside)
                if currentSelectedButton == iteratingButton {
                    currentSelectedButton = nil
                }
                buttonsArray.removeAtIndex(index)
            }
        }
    }
    
    func selected(sender: UIButton) {
        if(sender.selected) {
            sender.selected = false
        } else {
            for aButton in buttonsArray {
                aButton.selected = false
            }
            sender.selected = true
        }
    }
    
    func selectedButton() -> UIButton? {
        return currentSelectedButton
    }
}
