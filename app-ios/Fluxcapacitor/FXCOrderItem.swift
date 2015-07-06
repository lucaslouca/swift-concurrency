//
//  FXCOrderItem.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//
// Items contained in an order. Decorator for an FXCItem containing quantity etc.

import UIKit

class FXCOrderItem: NSObject {
    var item: FXCItem!
    var quantity: Double = 0
    var quantityUnit: String = ""
}
