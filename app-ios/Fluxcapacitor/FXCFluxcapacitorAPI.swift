//
//  FXCFluxcapacitorAPI.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 22/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCFluxcapacitorAPI: NSObject, FXCItemFetchDelegate {
    let orderDataSourceURL = NSURL(string:"http://lucaslouca.com/swift-concurrency/orders.plist")
    let itemsDataSourceURL = NSURL(string:"http://lucaslouca.com/swift-concurrency/items.plist")
    let pendingOperations: FXCPendingOperations = FXCPendingOperations()
    var items = [Int:FXCItem]()
    
    /**
    Read-Only computed property sharedInstance holding the the shared API object.
    */
    class var sharedInstance: FXCFluxcapacitorAPI {
        struct Singleton {
            static let instance = FXCFluxcapacitorAPI()
        }
        return Singleton.instance
    }
    
    /**
    This method creates an asynchronous web request which, when finished, will run the completion block on the main queue.
    When the download is complete the property list data is extracted into an NSDictionary and then processed again into an
    array of FXCOrder objects.
    
    - parameter delegate: FXCOrderFetchDelegate the should get notified when the order details are downloaded
    */
    func fetchOrderDetails(delegate: FXCOrderFetchDelegate) {
        let request = NSURLRequest(URL:orderDataSourceURL!)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {response, data, error in
            do {
                if data != nil {
                    var orderDetails = [FXCOrder]()
                    let datasourceDictionary = try NSPropertyListSerialization.propertyListWithData(data!, options: NSPropertyListMutabilityOptions.Immutable, format: nil) as! NSDictionary
                    for(key, value): (AnyObject, AnyObject) in datasourceDictionary {
                        let orderId = key as? String
                        let url = NSURL(string:value as? String ?? "")
                        if orderId != nil && url != nil {
                            let order = FXCOrder(id:Int(orderId!)!, url:url!)
                            orderDetails.append(order)
                        }
                    }
                    
                    // Notify delegate that order details fetching is complete
                    delegate.orderDetailsFetchDidFinishWith(orderDetails)
                }
                
                if error != nil {
                    let alert = UIAlertView(title:"Oops!",message:error!.localizedDescription, delegate:nil, cancelButtonTitle:"OK")
                    alert.show()
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            } catch {
                print("Unable to complete request. \(error)")
            }
        }
    }
    
    /**
    Start the download of data for the given order at indexPath.
    
    - parameter order: the FXCOrder containing the details (URL to order XML) inorder to download the full order data (price, images etc)
    
    - parameter indexPath: NSIndexPath of the order
    
    - parameter delegate: FXCOrderFetchDelegate the should get notified when the order data are downloaded
    */
    func startDownloadForOrder(order: FXCOrder, indexPath: NSIndexPath, delegate: FXCOrderFetchDelegate){
        if let _ = pendingOperations.orderDownloadsInProgress[indexPath] {
            return
        }
        
        let downloadOperation = FXCOperationOrderDownloader(order: order)
        downloadOperation.completionBlock = {
            if downloadOperation.cancelled {
                return
            }
            
            // UI stuff needs to be done on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.orderDownloadsInProgress.removeValueForKey(indexPath)
                
                // Notify delegate that the order has been downloaded
                delegate.orderDownloadDidFinishForIndexPath(indexPath)
            })
        }
        
        pendingOperations.orderDownloadsInProgress[indexPath] = downloadOperation
        pendingOperations.orderDownloadQueue.addOperation(downloadOperation)
    }
    
    /**
    Get a Set of all pending order operations (download and XML parsing)
    
    :return: Set of all pending order operations (download and XML parsing)
    */
    func allPendingOrderOperations() -> Set<NSIndexPath> {
        var result = Set(pendingOperations.orderDownloadsInProgress.keys.array)
        result.unionInPlace(pendingOperations.orderXMLParsingInProgress.keys.array)
        return result
    }
    
    /**
    Cancel the download of the order with indexPath.
    
    - parameter indexPath: NSIndexPath of the order
    */
    func cancelDownloadOrderOperation(indexPath: NSIndexPath) {
        if let pendingDownload = pendingOperations.orderDownloadsInProgress[indexPath] {
            pendingDownload.cancel()
        }
        pendingOperations.orderDownloadsInProgress.removeValueForKey(indexPath)
    }
    
    
    /**
    Start the XML parsing of the downloaded order data for the given order at indexPath.
    
    - parameter order: the FXCOrder containing the data (NSData) that needs to pased and mapped to the FXCOrder attributes
    
    - parameter indexPath: NSIndexPath of the order
    
    - parameter delegate: FXCOrderFetchDelegate the should get notified when the order data parsing is done
    */
    func startXMPParsingForOrder(order: FXCOrder, indexPath: NSIndexPath, delegate: FXCOrderFetchDelegate){
        if let _ = pendingOperations.orderXMLParsingInProgress[indexPath] {
            return
        }
        
        let parseOperation = FXCOperationOrderXMLParse(order: order)
        parseOperation.completionBlock = {
            if parseOperation.cancelled {
                return
            }
            
            // UI stuff needs to be done on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.orderXMLParsingInProgress.removeValueForKey(indexPath)
                
                // Notify delegate that the order has been parsed
                delegate.orderXMParsingDidFinishForIndexPath(indexPath)
            })
        }
        
        pendingOperations.orderXMLParsingInProgress[indexPath] = parseOperation
        pendingOperations.orderXMLParsingQueue.addOperation(parseOperation)
    }
    
    /**
    Cancel the XML parsing of the order with indexPath.
    
    - parameter indexPath: NSIndexPath of the order
    */
    func cancelXMLParsingOrderOperation(indexPath: NSIndexPath) {
        if let pendingDownload = pendingOperations.orderXMLParsingInProgress[indexPath] {
            pendingDownload.cancel()
        }
        pendingOperations.orderXMLParsingInProgress.removeValueForKey(indexPath)
    }
    
    func suspendAllOrderDownloads() {
        pendingOperations.orderDownloadQueue.suspended = true
    }
    
    func suspendAllOrderXMLParsingOperations() {
        pendingOperations.orderXMLParsingQueue.suspended = true
    }
    
    func resumeAllOrderDownloads() {
        pendingOperations.orderDownloadQueue.suspended = false
    }
    
    func resumeAllOrderXMLParsingOperations() {
        pendingOperations.orderXMLParsingQueue.suspended = false
    }
    
    // MARK: - Items Download
    func fetchItems(){
        self.fetchItemDetails(self)
    }
    
    /**
    Fetch the list of all item IDs with the URL to their XML file: (id, URL)
    */
    func fetchItemDetails(delegate: FXCItemFetchDelegate) {
        let request = NSURLRequest(URL:itemsDataSourceURL!)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {response, data, error in
            do {
                if data != nil {
                    var itemDetails = [Int:FXCItem]()
                    let datasourceDictionary = try NSPropertyListSerialization.propertyListWithData(data!, options: NSPropertyListMutabilityOptions.Immutable, format: nil)  as! NSDictionary
                    for(key, value): (AnyObject, AnyObject) in datasourceDictionary {
                        let itemId = key as? String
                        let url = NSURL(string:value as? String ?? "")
                        if itemId != nil && url != nil {
                            let item = FXCItem(id:Int(itemId!)!, url:url!)
                            itemDetails[item.id] = item
                        }
                    }
                    
                    // Notify delegate that order details fetching is complete
                    delegate.itemDetailsFetchDidFinishWith(itemDetails)
                }
                
                if error != nil {
                    let alert = UIAlertView(title:"Oops!",message:error!.localizedDescription, delegate:nil, cancelButtonTitle:"OK")
                    alert.show()
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
            } catch {print("Unable to complete request. \(error)")}
        }
    }
    
    /**
    Stage 1:
    Called when we have all the item id and URL to their XML
    */
    func itemDetailsFetchDidFinishWith(itemDetails:[Int:FXCItem]) {
        items = itemDetails
        for (_, item) in items {
            FXCFluxcapacitorAPI.sharedInstance.startOperationsForItem(item)
        }
    }
    
    /**
    Stage 2:
    Called when we have the XML data for an item (not parsed)
    */
    func itemDownloadDidFinishForItem(item: FXCItem) {
        FXCFluxcapacitorAPI.sharedInstance.startOperationsForItem(item)
    }
    
    /**
    Stage 3:
    Called when we have parsed the XML data of an item
    */
    func itemXMParsingDidFinishForItem(item: FXCItem) {
        FXCFluxcapacitorAPI.sharedInstance.startOperationsForItem(item)
    }
    
    /**
    Stage 4:
    Called when the image of an item has been downloaded
    */
    func itemImageDownloadDidFinishForItem(item: FXCItem) {
        
    }
    
    func startOperationsForItem(itemDetails: FXCItem) {
        switch (itemDetails.state) {
        case .New:
            FXCFluxcapacitorAPI.sharedInstance.startDownloadForItem(itemDetails, delegate:self)
        case .Downloaded:
            FXCFluxcapacitorAPI.sharedInstance.startXMPParsingForItem(itemDetails, delegate:self)
        case .XMLParsed:
            FXCFluxcapacitorAPI.sharedInstance.startImageDownloadForItem(itemDetails, delegate:self)
        default:
            NSLog("")
        }
    }
    
    
    /**
    Start the download of data for the given item.
    
    - parameter item: the FXCItem containing the details (URL to order XML) inorder to download the full order data (weight, name, image-url etc)
    
    
    - parameter delegate: FXCItemFetchDelegate the should get notified when the item data are downloaded
    */
    func startDownloadForItem(item: FXCItem, delegate: FXCItemFetchDelegate){
        if let _ = pendingOperations.itemDownloadsInProgress[item.id] {
            return
        }
        
        let downloadOperation = FXCOperationItemDownloader(item: item)
        downloadOperation.completionBlock = {
            if downloadOperation.cancelled {
                return
            }
            
            // UI stuff needs to be done on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.itemDownloadsInProgress.removeValueForKey(item.id)
                
                // Notify delegate that the order has been downloaded
                delegate.itemDownloadDidFinishForItem(item)
            })
        }
        
        pendingOperations.itemDownloadsInProgress[item.id] = downloadOperation
        pendingOperations.itemDownloadQueue.addOperation(downloadOperation)
    }
    
    /**
    Start the XML parsing of the downloaded item data for the given item.
    
    - parameter item: the FXCItem containing the data (NSData) that needs to pased and mapped to the FXCItem fields
    
    - parameter delegate: FXCItemFetchDelegate the should get notified when the item data parsing is done
    */
    func startXMPParsingForItem(item: FXCItem, delegate: FXCItemFetchDelegate){
        if let _ = pendingOperations.itemXMLParsingInProgress[item.id] {
            return
        }
        
        let parseOperation = FXCOperationItemXMLParse(item: item)
        parseOperation.completionBlock = {
            if parseOperation.cancelled {
                return
            }
            
            // UI stuff needs to be done on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.itemXMLParsingInProgress.removeValueForKey(item.id)
                
                // Notify delegate that the item has been parsed
                delegate.itemXMParsingDidFinishForItem(item)
            })
        }
        
        pendingOperations.itemXMLParsingInProgress[item.id] = parseOperation
        pendingOperations.itemXMLParsingQueue.addOperation(parseOperation)
    }
    
    /**
    Start the image download of a parsed item.
    
    - parameter item: the FXCItem containing the URL of the image
    
    - parameter delegate: FXCItemFetchDelegate the should get notified when the image download is done
    */
    func startImageDownloadForItem(item: FXCItem, delegate: FXCItemFetchDelegate){
        if let _ = pendingOperations.itemImageDownloadsInProgress[item.id] {
            return
        }
        
        let parseOperation = FXCOperationItemImageDownloader(item: item)
        parseOperation.completionBlock = {
            if parseOperation.cancelled {
                return
            }
            
            // UI stuff needs to be done on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.itemImageDownloadsInProgress.removeValueForKey(item.id)
                
                // Notify delegate that the item has been parsed
                delegate.itemImageDownloadDidFinishForItem?(item)
            })
        }
        
        pendingOperations.itemImageDownloadsInProgress[item.id] = parseOperation
        pendingOperations.itemImageDownloadQueue.addOperation(parseOperation)
    }
    
}