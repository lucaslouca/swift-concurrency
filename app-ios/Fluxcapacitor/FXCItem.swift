//
//  FXCItemImageRecord.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

enum FXCItemState {
    case New, Downloaded, Failed, XMLParsed, Parsed
}

class FXCItem: NSObject {
    var state = FXCItemState.New
    let url:NSURL
    let id:Int
    var data: NSData?
    
    
    var imageUrl: String = ""
    var image = UIImage(named: "Placeholder")
    var name: String = ""
    
    init(id: Int, url:NSURL) {
        self.id = id
        self.url = url
    }
}
