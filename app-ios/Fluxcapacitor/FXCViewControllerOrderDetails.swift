//
//  FXCViewControllerOrderDetails.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 25/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit
import MapKit

class FXCViewControllerOrderDetails: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var order: FXCOrder!
    let tableCellMapIdentifier = "FXCTableViewCellOrderDetailsMap"
    let tableCellDeliveryDetailsIdentifier = "FXCTableViewCellOrderDetailsDeliveryDetails"
    let tableCellItemIdentifier = "FXCTableViewCellItemOrderDetails"
    let deliveryDetailsCellHeight: CGFloat = 130
    let itemCellHeight: CGFloat = 60
    let sectionHeaderHeight: CGFloat = 25
    let sectionTitle:[Int:String] = [0:"DETAILS", 1:"ITEMS"]
    var mapView: MKMapView!
    
    var tableHeaderView: FXCViewParallaxTableHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register table cell nib
        var tableViewCellNib = UINib(nibName: tableCellDeliveryDetailsIdentifier, bundle: nil)
        tableView.registerNib(tableViewCellNib, forCellReuseIdentifier: tableCellDeliveryDetailsIdentifier)
        
        tableViewCellNib = UINib(nibName: tableCellItemIdentifier, bundle: nil)
        tableView.registerNib(tableViewCellNib, forCellReuseIdentifier: tableCellItemIdentifier)
        
        // Init table headerView and mapView
        let tableHeaderViewHeight = getHeightForTableHeaderView()
        mapView = MKMapView(frame: CGRectMake(0,0, self.view.frame.width, tableHeaderViewHeight))
        tableHeaderView = FXCViewParallaxTableHeader(size: CGSizeMake(self.view.frame.width, tableHeaderViewHeight), subView: mapView)
        tableView.tableHeaderView = tableHeaderView
        
        showLocationInMapView()

        // Device Orientation
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    /**
    Computes available space on the screen for the tableHeaderView and returns a CGFloat
    representing the tableHeaderView height
    
    :return: CGFloat tableHeaderView height
    */
    func getHeightForTableHeaderView() -> CGFloat {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var result:CGFloat = screenSize.height - deliveryDetailsCellHeight
        if let navigationBar = self.navigationController?.navigationBar {
            result -= navigationBar.frame.height
        }
        
        return result
    }
    
    /**
    Called when the device is rotated
    */
    func rotated() {
        let header: FXCViewParallaxTableHeader = self.tableView.tableHeaderView as! FXCViewParallaxTableHeader
        let tableHeaderViewHeight = getHeightForTableHeaderView()
        header.frame = CGRectMake(0,0, self.view.frame.width, tableHeaderViewHeight)
        
        self.tableView.tableHeaderView = header
    }

    /**
    Shows the order's location in the map view
    */
    func showLocationInMapView() {
        let location = CLLocationCoordinate2D(
            latitude: order.latitude,
            longitude: order.longitude
        )
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = order.title
        annotation.subtitle = order.info
        mapView.addAnnotation(annotation)
    }
}

// MARK: - UITableViewDataSource
extension FXCViewControllerOrderDetails {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = NSBundle.mainBundle().loadNibNamed("FXCViewSectionHeader", owner: self, options: nil)[0] as? FXCViewSectionHeader
        titleView!.frame = CGRectMake(0, 0, self.tableView.frame.width, sectionHeaderHeight)
        titleView!.titleLabel.text = sectionTitle[section]
        return titleView
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return order.items.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return deliveryDetailsCellHeight
        } else {
            return itemCellHeight
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(tableCellDeliveryDetailsIdentifier) as! FXCTableViewCellOrderDetailsDeliveryDetails
            cell.dateTimeLabel.text = order.deliveryDate
            cell.addressLabel.text = order.address
            cell.priceLabel.text = "\(order.price) \(order.currency)"
            return cell
        } else if (indexPath.section == 1) {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(tableCellItemIdentifier) as! FXCTableViewCellItemOrderDetails
            let itemIndex = indexPath.row
            let orderItem: FXCOrderItem = order.items[itemIndex]
            let item: FXCItem = orderItem.item
            cell.itemImageView.image = item.image
            cell.itemNameLabel.text = item.name
            cell.itemQuantityLabel.text = "\(orderItem.quantity) \(orderItem.quantityUnit)"
            
            // to avoid shifting to the right by 15.0 points
            cell.itemImageView.frame = CGRectMake(0, 0, 0, 0)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: - ScrollView
extension FXCViewControllerOrderDetails {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let header: FXCViewParallaxTableHeader = self.tableView.tableHeaderView as! FXCViewParallaxTableHeader
        header.layoutForScrollViewContentOffset(tableView.contentOffset)
        
        self.tableView.tableHeaderView = header
        
    }
}