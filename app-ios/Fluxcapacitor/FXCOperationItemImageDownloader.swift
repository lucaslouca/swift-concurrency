//
//  FXCOperationItemImageDownloader.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCOperationItemImageDownloader: NSOperation {
    let item: FXCItem
    
    init(item: FXCItem) {
        self.item = item
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        self.item.imageUrl = self.item.imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        let url = NSURL(string: self.item.imageUrl)
        let imageData = NSData(contentsOfURL:url!)
        
        if self.cancelled {
            return
        }
           
        if imageData?.length > 0 {
            self.item.image = UIImage(data:imageData!)
            self.item.state = .Parsed
        } else {
            self.item.state = .Failed
            self.item.image = UIImage(named: "Failed")
        }
    }
}
