//
//  FXCOperationOrderXMLParse.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 30/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCOperationOrderXMLParse: NSOperation, NSXMLParserDelegate {
    let order: FXCOrder
    var element: String?
    typealias PropertyNameValueType = (propertyName: String, value: NSMutableString, type: Any)
    var xmlElement2PropertyNameValueType = [String:PropertyNameValueType]()
    var xmlItemElement2PropertyNameValueType = [String:PropertyNameValueType]()
    
    var processingItem = false
    
    init(order: FXCOrder) {
        self.order = order
        
        // Register XML element with FXCOrder property name, initial empty value and type
        xmlElement2PropertyNameValueType["title"] = ("title", NSMutableString(), String())
        xmlElement2PropertyNameValueType["info"] = ("info", NSMutableString(), String())
        xmlElement2PropertyNameValueType["price"] = ("price", NSMutableString(), Int())
        xmlElement2PropertyNameValueType["itemCount"] = ("itemCount", NSMutableString(), Int())
        xmlElement2PropertyNameValueType["address"] = ("address", NSMutableString(), String())
        xmlElement2PropertyNameValueType["radius"] = ("radius", NSMutableString(), Int())
        xmlElement2PropertyNameValueType["radiusUnit"] = ("radiusUnit", NSMutableString(), String())
        xmlElement2PropertyNameValueType["latitude"] = ("latitude", NSMutableString(), Double())
        xmlElement2PropertyNameValueType["longitude"] = ("longitude", NSMutableString(), Double())
        xmlElement2PropertyNameValueType["deliveryDate"] = ("deliveryDate", NSMutableString(), String())
        xmlElement2PropertyNameValueType["currency"] = ("currency", NSMutableString(), String())
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        if self.order.state != .Downloaded {
            return
        }
        
        applyParseXML(self.order)
        self.order.state = .Parsed
    }
    
    /**
    Instantiate a new item property2value map with empty values
    */
    func registerNewItemMap() {
        xmlItemElement2PropertyNameValueType = [String:PropertyNameValueType]()
        xmlItemElement2PropertyNameValueType["id"] = ("id", NSMutableString(), String())
        xmlItemElement2PropertyNameValueType["quantity"] = ("quantity", NSMutableString(), Double())
        xmlItemElement2PropertyNameValueType["quantityUnit"] = ("quantityUnit", NSMutableString(), String())
    }
    
    func applyParseXML(order: FXCOrder) {
        let xmlParser = NSXMLParser(data: order.data!)
        xmlParser.delegate = self
        xmlParser.parse()
    }
    
    // MARK: - NSXMLParserDelegate
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        if self.cancelled {
            return
        }
        
        element = elementName
        
        if (element == "item") {
            processingItem = true
            registerNewItemMap()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if (!processingItem) {
            // Not proccessing Item
            let tuple = xmlElement2PropertyNameValueType[element!] as PropertyNameValueType?
            if (tuple != nil){
                tuple!.value.appendString(string)
            }
        } else {
            // Currently Proccessing Item
            let tuple = xmlItemElement2PropertyNameValueType[element!] as PropertyNameValueType?
            if (tuple != nil){
                tuple!.value.appendString(string)
            }
        }
    }
    
    // Sent to delegate when the parser has finished reading an element
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // If the XML parser did finish reading the element 'order' then we reached the end. We can now start filling out the FXCOrder properties.
        if elementName == "order" {
            let mirror = reflect(self.order)
            for (_, tuple) in xmlElement2PropertyNameValueType {
                for index in 0..<mirror.count {
                    let (propertyName, _) = mirror[index]
                    if propertyName == tuple.propertyName {
                        switch tuple.type {
                        case is Int:
                            self.order.setValue(tuple.value.integerValue, forKey: propertyName)
                        case is Double:
                            self.order.setValue(tuple.value.doubleValue, forKey: propertyName)
                        case is String:
                            self.order.setValue(tuple.value, forKey: propertyName)
                        default:
                            NSLog("Uknown type")
                        }
                        
                    }
                }
            }
        }
        
        
        if (elementName == "item") {
            processingItem = false
            let item = FXCOrderItem()
            let mirror = reflect(item)
            for (_, tuple) in xmlItemElement2PropertyNameValueType {
                for index in 0..<mirror.count {
                    let (propertyName, _) = mirror[index]
                    if (tuple.propertyName == "id") {
                        // id is not a property of an FXCOrderItem, so we dont map it through reflection
                        item.item = FXCFluxcapacitorAPI.sharedInstance.items[tuple.value.integerValue]
                    } else {
                        if propertyName == tuple.propertyName {
                            switch tuple.type {
                            case is Int:
                                item.setValue(tuple.value.integerValue, forKey: propertyName)
                            case is Double:
                                item.setValue(tuple.value.doubleValue, forKey: propertyName)
                            case is String:
                                item.setValue(tuple.value, forKey: propertyName)
                            default:
                                NSLog("Uknown type")
                            }
                            
                        }
                    }
                }
            }
            
            self.order.items.append(item)
            registerNewItemMap()
        }
    }
}