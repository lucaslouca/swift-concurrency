//
//  FXCPendingOperations.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 22/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCPendingOperations {
    lazy var orderDownloadsInProgress = [NSIndexPath:NSOperation]()
    lazy var orderDownloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Order download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    lazy var orderXMLParsingInProgress = [NSIndexPath:NSOperation]()
    lazy var orderXMLParsingQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Order XML parsing queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    lazy var itemDownloadsInProgress = [Int:NSOperation]()
    lazy var itemDownloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Item download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    lazy var itemXMLParsingInProgress = [Int:NSOperation]()
    lazy var itemXMLParsingQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Item XML parsing queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    lazy var itemImageDownloadsInProgress = [Int:NSOperation]()
    lazy var itemImageDownloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Item image download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
}
