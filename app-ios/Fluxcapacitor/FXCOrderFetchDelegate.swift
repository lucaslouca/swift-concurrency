//
//  FXCOrderFetchDelegate.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 30/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@objc protocol FXCOrderFetchDelegate {
    /**
    Sent to delegate when the download of the order details has been successful
    
    - parameter array: of FXCOrder objects, each containing the neccesary details (URL to order XML file) to download the rest of the data for an order.
    */
    func orderDetailsFetchDidFinishWith(orderDetails:[FXCOrder])
    
    /**
    Sent to delegate when the download of an order's data is complete
    
    - parameter indexPath: NSIndexPath of the order downloaded
    */
    func orderDownloadDidFinishForIndexPath(indexPath: NSIndexPath)
    
    /**
    Sent to delegate when the XML parsing of an order's data is complete
    
    - parameter indexPath: NSIndexPath of the order parsed
    */
    func orderXMParsingDidFinishForIndexPath(indexPath: NSIndexPath)
}
