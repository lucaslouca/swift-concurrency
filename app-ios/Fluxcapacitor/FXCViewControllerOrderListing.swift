//
//  FXCViewControllerOrderListing.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 24/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCViewControllerOrderListing: UIViewController, UITableViewDelegate, UITableViewDataSource, FXCOrderFetchDelegate, UISearchResultsUpdating {
    @IBOutlet weak var orderListingTableView: UITableView!
    @IBOutlet weak var numberOfResultsLabel: UILabel!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var barView: FXCBorderView!
    @IBOutlet weak var orderListingTableViewConstTop: NSLayoutConstraint!
    var searchController: UISearchController!
    let tableViewCellIdentifier = "FXCTableViewCellOrderListing"
    let segueToOrderDetails = "SegueToOrderDetails"
    let tableViewCellNibName = "FXCTableViewCellOrderListing"
    var orders = [FXCOrder]()
    var filteredOrders = [FXCOrder]()
    var selectedOrder: FXCOrder?
    var refreshControl: UIRefreshControl!
    var refreshLoadingView : UIView!
    var refreshColorView : UIView!
    var compass_background : UIImageView!
    var compass_spinner : UIImageView!
    var isRefreshIconsOverlap = false
    var isRefreshAnimating = false
    var sortDropDownView: UIView!
    var sortDropDownViewConstHeight: NSLayoutConstraint!
    var sortDropDownIsExpanded = false
    var currentSorting: FXCSortAttribute = FXCSortAttribute.None
    
    enum FXCSortOrder {
        case Descending, Ascending
    }
    
    enum FXCSortAttribute {
        case None, PriceDescending, PriceAscending
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup search
        setupSearch()
        
        // Hide navigation bars shadow image and setup colors
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        
        
        // Register table cell nib
        let tableViewCellNib = UINib(nibName: tableViewCellNibName, bundle: nil)
        orderListingTableView.registerNib(tableViewCellNib, forCellReuseIdentifier: tableViewCellIdentifier)
        
        // Setup pull and refresh
        setupRefreshControl()
        
        // Setup dropdown for sorting
        setupSortDropDownView()
        
        // Fetch Order meta information
        FXCFluxcapacitorAPI.sharedInstance.fetchOrderDetails(self)
    }
    
    // MARK: - Sorting
    
    func setupSortDropDownView() {
        sortDropDownView = NSBundle.mainBundle().loadNibNamed("FXCViewOrderListingSort", owner: self, options: nil)[0] as? UIView
        sortDropDownView.frame = CGRectMake(0, 0, self.view.frame.width, 200)
        sortDropDownView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sortDropDownView!)
        let constTop = NSLayoutConstraint(item: sortDropDownView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: barView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let constWidth = NSLayoutConstraint(item: sortDropDownView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        sortDropDownViewConstHeight = NSLayoutConstraint(item: sortDropDownView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        
        self.view.addConstraint(constTop)
        self.view.addConstraint(constWidth)
        self.view.addConstraint(sortDropDownViewConstHeight)
        sortDropDownView.alpha = 0.0
    }
    
    /**
    Button action when the sort button is tapped. This action toggles the sort drop down menu view's visibility
    */
    @IBAction func sortButtonTapped(sender: AnyObject) {
        let sortDropDownViewExpandedHeight: CGFloat = 37.0
        let sortDropDownViewHiddenHeight: CGFloat = 0.0
        
        if (!sortDropDownIsExpanded) {
            UIView.animateWithDuration(0.2, animations: {
                self.sortDropDownView.frame = CGRectMake(self.sortDropDownView.frame.origin.x, self.sortDropDownView.frame.origin.y, self.view.frame.width, sortDropDownViewExpandedHeight)
                self.orderListingTableView.frame = CGRectMake(self.orderListingTableView.frame.origin.x, self.orderListingTableView.frame.origin.y + sortDropDownViewExpandedHeight, self.orderListingTableView.frame.width, self.orderListingTableView.frame.height - sortDropDownViewExpandedHeight)
                self.sortDropDownView.alpha = 1.0
                }, completion: {
                    (complete: Bool) in
                    self.sortDropDownViewConstHeight.constant = sortDropDownViewExpandedHeight
                    self.orderListingTableViewConstTop.constant = sortDropDownViewExpandedHeight
                    self.sortDropDownIsExpanded = true
            })
        } else {
            UIView.animateWithDuration(0.2, animations: {
                self.sortDropDownView.frame = CGRectMake(self.sortDropDownView.frame.origin.x, self.sortDropDownView.frame.origin.y, self.view.frame.width, sortDropDownViewHiddenHeight)
                self.orderListingTableView.frame = CGRectMake(self.orderListingTableView.frame.origin.x, self.orderListingTableView.frame.origin.y - sortDropDownViewExpandedHeight, self.orderListingTableView.frame.width, self.orderListingTableView.frame.height + sortDropDownViewExpandedHeight)
                self.sortDropDownView.alpha = 0.0
                }, completion: {
                    (complete: Bool) in
                    self.sortDropDownViewConstHeight.constant = sortDropDownViewHiddenHeight
                    self.orderListingTableViewConstTop.constant = sortDropDownViewHiddenHeight
                    self.sortDropDownIsExpanded = false
            })
        }
    }
    
    /**
    Sorts orders in table view by price descending (15, 14, 9, ....) or ascending (9, 14, 15 ...)
    
    - parameter FXCSortOrder: the sorting order to perform
    */
    func sortByPriceUsingSortOrder(sortOrder: FXCSortOrder) {
        // We need an unsorted copy of the array for the animation
        let unsortedOrders = orders
        
        // Sort the elements and replace the array used by the data source with the sorted ones
        if (sortOrder == FXCSortOrder.Descending) {
            orders.sortInPlace { $0.price > $1.price }
        } else if (sortOrder == FXCSortOrder.Ascending) {
            orders.sortInPlace { $0.price < $1.price }
        }
        
        updateTableWithSorting(unsortedOrders)
    }
    
    /**
    Changes the order of the items in the table view based on the old and new order array
    
    - parameter [FXCOrder]: array of unsorted orders
    */
    func updateTableWithSorting(unsortedOrders:[FXCOrder]) {
        // Prepare table for the animations batch
        orderListingTableView.beginUpdates()
        
        // Move the cells around
        var sourceRow = 0;
        for order in unsortedOrders {
            let destRow = orders.indexOf(order)
            
            if (destRow != sourceRow) {
                // Move the rows within the table view
                let sourceIndexPath = NSIndexPath(forItem: sourceRow, inSection: 0)
                let destIndexPath = NSIndexPath(forItem: destRow!, inSection: 0)
                orderListingTableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: destIndexPath)
                
                // Alternate row colors
                if destIndexPath.row % 2 == 1 {
                    orderListingTableView.cellForRowAtIndexPath(sourceIndexPath)?.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
                } else {
                    orderListingTableView.cellForRowAtIndexPath(sourceIndexPath)?.backgroundColor = UIColor.whiteColor()
                }
            }
            
            sourceRow++
        }
        orderListingTableView.endUpdates()
    }
    
    /**
    Applies the sorting on the order array based on the currentSorting value
    */
    func applySorting() {
        // Do sorting when new orders finished parsing
        switch currentSorting {
        case .PriceAscending:
            sortByPriceUsingSortOrder(FXCSortOrder.Ascending)
        case .PriceDescending:
            sortByPriceUsingSortOrder(FXCSortOrder.Descending)
        default:
            NSLog("no sorting")
        }
    }
    
    @IBAction func buttonSortPriceAscendingTapped(sender: AnyObject) {
        if let button = sender as? UIButton {
            if (button.selected) {
                sortByPriceUsingSortOrder(FXCSortOrder.Ascending)
                currentSorting = FXCSortAttribute.PriceAscending
            } else {
                currentSorting = FXCSortAttribute.None
            }
        }
    }
    
    @IBAction func buttonSortPriceDescendingTapped(sender: AnyObject) {
        if let button = sender as? UIButton {
            if (button.selected) {
                sortByPriceUsingSortOrder(FXCSortOrder.Descending)
                currentSorting = FXCSortAttribute.PriceDescending
            } else {
                currentSorting = FXCSortAttribute.None
            }
        }
    }
    
    // MARK: - Operations
    func startOperationsForOrder(orderDetails:FXCOrder, indexPath: NSIndexPath) {
        switch (orderDetails.state) {
        case .New:
            FXCFluxcapacitorAPI.sharedInstance.startDownloadForOrder(orderDetails, indexPath: indexPath, delegate:self)
        case .Downloaded:
            FXCFluxcapacitorAPI.sharedInstance.startXMPParsingForOrder(orderDetails, indexPath: indexPath, delegate:self)
        default:
            NSLog("")
        }
    }
    
    func suspendAllOperations() {
        FXCFluxcapacitorAPI.sharedInstance.suspendAllOrderDownloads()
        FXCFluxcapacitorAPI.sharedInstance.suspendAllOrderXMLParsingOperations()
    }
    
    func resumeAllOperations() {
        FXCFluxcapacitorAPI.sharedInstance.resumeAllOrderDownloads()
        FXCFluxcapacitorAPI.sharedInstance.resumeAllOrderXMLParsingOperations()
    }
    
    /**
    Cancel processing of off-screen cells and prioritize the cells that are currently displayed.
    */
    func loadOrdersForOnscreenCells () {
        // Start with an array containing index paths of all the currently visible rows in the table view.
        if let pathsArray = orderListingTableView.indexPathsForVisibleRows {
            // Get a set of all pending operations by combining all the downloads in progress + all the XML parsers in progress.
            let allPendingOperations = FXCFluxcapacitorAPI.sharedInstance.allPendingOrderOperations()
            
            //Construct a set of all index paths with operations to be cancelled. Start with all operations, and then remove the index paths of the visible rows. This will leave the set of operations involving off-screen rows.
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray as [NSIndexPath])
            toBeCancelled.subtractInPlace(visiblePaths)
            
            //Construct a set of index paths that need their operations started. Start with index paths all visible rows, and then remove the ones where operations are already pending.
            var toBeStarted = visiblePaths
            toBeStarted.subtractInPlace(allPendingOperations)
            
            //Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
            for indexPath in toBeCancelled {
                FXCFluxcapacitorAPI.sharedInstance.cancelDownloadOrderOperation(indexPath)
                FXCFluxcapacitorAPI.sharedInstance.cancelXMLParsingOrderOperation(indexPath)
            }
            
            // Loop through those to be started, and call startOperationsForOrder for each.
            for indexPath in toBeStarted {
                let indexPath = indexPath as NSIndexPath
                let orderToProcess = orders[indexPath.row]
                startOperationsForOrder(orderToProcess, indexPath:indexPath)
            }
        }
    }
    
    // MARK: - Search
    func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.frame = CGRectMake(0, 0, searchBarView.frame.width, searchBarView.frame.height)
        searchController.searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        searchController.searchBar.placeholder = "Address"
        searchController.searchBar.layer.borderColor = UIColor.whiteColor().CGColor
        searchController.searchBar.layer.borderWidth = 1.0
        
        searchController.searchBar.barTintColor = UIColor.whiteColor()
        let searchField = searchController.searchBar.valueForKey("searchField") as! UITextField
        searchField.backgroundColor = UIColor.whiteColor()
        searchField.layer.borderColor = UIColor.lightGrayColor().CGColor
        searchField.layer.borderWidth = 1.0
        
        searchBarView.addSubview(searchController.searchBar)
    }
    
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredOrders = self.orders.filter({( order: FXCOrder) -> Bool in
            let stringMatch = order.address.rangeOfString(searchText)
            return (stringMatch != nil)
        })
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueToOrderDetails {
            if let destination = segue.destinationViewController as? FXCViewControllerOrderDetails {
                if selectedOrder != nil {
                    destination.order = selectedOrder
                }
            }
        }
    }
    
    /**
    Action performed when a detail button in the table view cell is tapped
    */
    func detailButtonTapped(sender:UIButton!) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: orderListingTableView)
        if let orderIndex = orderListingTableView.indexPathForRowAtPoint(buttonPosition) {
            if (searchController.active) {
                selectedOrder = filteredOrders[orderIndex.row]
            } else {
                selectedOrder = orders[orderIndex.row]
            }
            performSegueWithIdentifier(segueToOrderDetails, sender: self)
        }
    }
    
    // MARK: - Pull to Refresh
    func setupRefreshControl() {
        // Programmatically inserting a UIRefreshControl
        self.refreshControl = UIRefreshControl()
        orderListingTableView.addSubview(refreshControl)
        
        // Setup the loading view, which will hold the moving graphics
        self.refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        self.refreshLoadingView.backgroundColor = UIColor.clearColor()
        
        // Setup the color view, which will display the rainbowed background
        self.refreshColorView = UIView(frame: self.refreshControl!.bounds)
        self.refreshColorView.backgroundColor = UIColor.clearColor()
        self.refreshColorView.alpha = 0.30
        
        // Create the graphic image views
        compass_background = UIImageView(image: UIImage(named: "compass_background.png"))
        self.compass_spinner = UIImageView(image: UIImage(named: "compass_spinner.png"))
        
        // Add the graphics to the loading view
        self.refreshLoadingView.addSubview(self.compass_background)
        self.refreshLoadingView.addSubview(self.compass_spinner)
        
        // Clip so the graphics don't stick out
        self.refreshLoadingView.clipsToBounds = true;
        
        // Hide the original spinner icon
        self.refreshControl!.tintColor = UIColor.clearColor()
        
        // Add the loading and colors views to our refresh control
        self.refreshControl!.addSubview(self.refreshColorView)
        self.refreshControl!.addSubview(self.refreshLoadingView)
        
        // Initalize flags
        self.isRefreshIconsOverlap = false;
        self.isRefreshAnimating = false;
        
        // When activated, invoke our refresh function
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(){
        FXCFluxcapacitorAPI.sharedInstance.fetchOrderDetails(self)
        
        let delayInSeconds = 1.0;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
    }
    
    func animateRefreshView() {
        // Background color to loop through for our color view
        
        var colorArray = [FXCDrawUtil.greenColor, FXCDrawUtil.orangeColor]
        
        // In Swift, static variables must be members of a struct or class
        struct ColorIndex {
            static var colorIndex = 0
        }
        
        // Flag that we are animating
        self.isRefreshAnimating = true;
        
        UIView.animateWithDuration(
            Double(0.2),
            delay: Double(0.0),
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                self.compass_spinner.transform = CGAffineTransformRotate(self.compass_spinner.transform, CGFloat(M_PI_2))
                
                // Change the background color
                self.refreshColorView!.backgroundColor = colorArray[ColorIndex.colorIndex]
                ColorIndex.colorIndex = (ColorIndex.colorIndex + 1) % colorArray.count
            },
            completion: { finished in
                // If still refreshing, keep spinning, else reset
                if (self.refreshControl!.refreshing) {
                    self.animateRefreshView()
                }else {
                    self.resetAnimation()
                }
            }
        )
    }
    
    func resetAnimation() {
        // Reset our flags and }background color
        self.isRefreshAnimating = false;
        self.isRefreshIconsOverlap = false;
        self.refreshColorView.backgroundColor = UIColor.clearColor()
    }
    
}

// MARK: - UISearchResultsUpdating
extension FXCViewControllerOrderListing {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        self.orderListingTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension FXCViewControllerOrderListing {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.active) {
            numberOfResultsLabel.text = "\(self.filteredOrders.count) orders"
            
            return filteredOrders.count
        } else {
            numberOfResultsLabel.text = "\(self.orders.count) orders"
            
            return orders.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FXCTableViewCellOrderListing = self.orderListingTableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier) as! FXCTableViewCellOrderListing
        
        // Alternate row colors
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        // Remove any accessoryView (e.g. DetailButton) because we are using a reusable cell
        cell.accessoryView = nil
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as? UIActivityIndicatorView
        
        cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        
        var orderDetails: FXCOrder!
        if (self.searchController.active) {
            orderDetails = filteredOrders[indexPath.row]
        } else {
            orderDetails = orders[indexPath.row]
        }
        
        // Fill details
        cell.priceLabel.text = "$\(orderDetails.price)"
        cell.itemCountLabel.text = "\(orderDetails.itemCount)"
        cell.dateLabel.text = "\(orderDetails.deliveryDate)"
        cell.radiusLabel.text = "\(orderDetails.radius) \(orderDetails.radiusUnit)"
        
        switch (orderDetails.state){
        case .New, .Downloaded:
            indicator?.startAnimating()
            if (!orderListingTableView.dragging && !orderListingTableView.decelerating) {
                startOperationsForOrder(orderDetails, indexPath:indexPath)
            }
        case .Parsed:
            indicator?.stopAnimating()
            let detailButton = FXCButtonDetail(frame: CGRectMake(0, 0, 30, 30))
            detailButton.borderColor = FXCDrawUtil.iconColor
            detailButton.borderWidth = 1.0
            detailButton.cornerRadius = 15.0
            detailButton.addTarget(self, action: "detailButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.accessoryView = detailButton
        case .Failed:
            indicator?.stopAnimating()
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - UITableViewDelegate
extension FXCViewControllerOrderListing {
    
    /**
    As soon as the user starts scrolling, we want to suspend all operations and take a look at what the user wants to see.
    */
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //If the value of decelerate is false, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
        if !decelerate {
            loadOrdersForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadOrdersForOnscreenCells()
        resumeAllOperations()
    }
    
    /**
    Show pull to refresh image
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Get the current size of the refresh controller
        var refreshBounds = self.refreshControl!.bounds
        
        // Distance the table has been pulled >= 0
        let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
        
        // Half the width of the table
        let midX = self.orderListingTableView.frame.size.width / 2.0
        
        // Calculate the width and height of our graphics
        let compassHeight = self.compass_background.bounds.size.height
        let compassHeightHalf = compassHeight / 2.0
        
        let compassWidth = self.compass_background.bounds.size.width
        let compassWidthHalf = compassWidth / 2.0
        
        let spinnerHeight = self.compass_spinner.bounds.size.height
        let spinnerHeightHalf = spinnerHeight / 2.0
        
        let spinnerWidth = self.compass_spinner.bounds.size.width
        let spinnerWidthHalf = spinnerWidth / 2.0
        
        // Calculate the pull ratio, between 0.0-1.0
        let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0
        
        // Set the Y coord of the graphics, based on pull distance
        let compassY = pullDistance / 2.0 - compassHeightHalf
        let spinnerY = pullDistance / 2.0 - spinnerHeightHalf
        
        // Calculate the X coord of the graphics, adjust based on pull ratio
        var compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio)
        var spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio)
        
        // When the compass and spinner overlap, keep them together
        if (fabsf(Float(compassX - spinnerX)) < 1.0) {
            self.isRefreshIconsOverlap = true
        }
        
        // If the graphics have overlapped or we are refreshing, keep them together
        if (self.isRefreshIconsOverlap || self.refreshControl!.refreshing) {
            compassX = midX - compassWidthHalf
            spinnerX = midX - spinnerWidthHalf
        }
        
        // Set the graphic's frames
        var compassFrame = self.compass_background.frame;
        compassFrame.origin.x = compassX
        compassFrame.origin.y = compassY
        
        var spinnerFrame = self.compass_spinner.frame;
        spinnerFrame.origin.x = spinnerX
        spinnerFrame.origin.y = spinnerY
        
        self.compass_background.frame = compassFrame
        self.compass_spinner.frame = spinnerFrame
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance
        
        self.refreshColorView.frame = refreshBounds
        self.refreshLoadingView.frame = refreshBounds
        
        // Set alpha
        self.compass_background.alpha = pullRatio
        self.compass_spinner.alpha  = pullRatio
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (self.refreshControl!.refreshing && !self.isRefreshAnimating) {
            self.animateRefreshView()
        }
    }
}

// MARK: - FXCOrderFetchDelegate
extension FXCViewControllerOrderListing {
    func orderDetailsFetchDidFinishWith(orderDetails:[FXCOrder]) {
        self.filteredOrders.removeAll(keepCapacity: false)
        self.orders = orderDetails
        if (searchController.active) {
            filterContentForSearchText(self.searchController.searchBar.text!)
        }
        self.orderListingTableView.reloadData()
    }
    
    func orderDownloadDidFinishForIndexPath(indexPath: NSIndexPath) {
        self.orderListingTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    func orderXMParsingDidFinishForIndexPath(indexPath: NSIndexPath) {
        if (currentSorting != FXCSortAttribute.None) {
            applySorting()
            // reload whole table, because moved cells that werent parsing (because they were not visible)
            // have become visible now (after the sorting) and should start parsing.
            self.orderListingTableView.reloadData()
        } else {
            self.orderListingTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}