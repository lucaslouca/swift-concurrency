//
//  FXCOperationItemImageDownloader.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCOperationItemDownloader: NSOperation {
    let item: FXCItem
    
    init(item: FXCItem) {
        self.item = item
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        let data = NSData(contentsOfURL:self.item.url)
        
        if self.cancelled {
            return
        }
        
        if (data != nil) {
            self.item.data = data;
            self.item.state = .Downloaded
        } else {
            self.item.state = .Failed
        }
    }
}
