//
//  FXCOperationOrderDownloader.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 30/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCOperationOrderDownloader: NSOperation {
    let order: FXCOrder
    
    init(order: FXCOrder) {
        self.order = order
    }
    
    override func main() {
        if self.cancelled {
            return
        }
  
        let data = NSData(contentsOfURL:self.order.url)
        
        if self.cancelled {
            return
        }
        
        if (data != nil) {
            self.order.data = data;
            self.order.state = .Downloaded
        } else {
            self.order.state = .Failed
        }
    }
}
