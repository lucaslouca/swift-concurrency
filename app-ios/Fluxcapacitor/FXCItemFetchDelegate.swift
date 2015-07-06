//
//  FXCItemFetchDelegate.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

@objc protocol FXCItemFetchDelegate {
    /**
    Sent to delegate when the download of the item details has been successful
    
    - parameter Dictionary: of FXCItem objects, each containing the neccesary details (URL to item XML file) to download the rest of the data for an item.
    */
    func itemDetailsFetchDidFinishWith(itemDetails:[Int:FXCItem])
    
    /**
    Sent to delegate when the download of an items's data is complete
    
    - parameter item: FXCItem downloaded
    */
    func itemDownloadDidFinishForItem(item: FXCItem)
    
    /**
    Sent to delegate when the XML parsing of an item's data is complete
    
    - parameter item: FXCItem parsed
    */
    func itemXMParsingDidFinishForItem(item: FXCItem)
    
    
    /**
    Sent to delegate when the image download of an items is complete
    
    - parameter item: FXCItem for which the image has been downloaded
    */
    optional func itemImageDownloadDidFinishForItem(item: FXCItem)
}
