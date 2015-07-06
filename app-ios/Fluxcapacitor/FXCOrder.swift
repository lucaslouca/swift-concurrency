//
//  FXCOrder.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 30/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

enum FXCOrderState {
    case New, Downloaded, Failed, Parsed
}

class FXCOrder: NSObject {
    var state = FXCOrderState.New
    let url:NSURL
    var data: NSData?
    let id:Int
    
    var title: String = ""
    var info: String = ""
    var price:Int = 0
    var itemCount: Int = 0
    var address: String = "a"
    var radius:Int = 0
    var radiusUnit: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var deliveryDate = ""
    var currency = ""
    var items:[FXCOrderItem] = [FXCOrderItem]()
    
    
    init(id: Int, url:NSURL) {
        self.id = id
        self.url = url
    }
}
