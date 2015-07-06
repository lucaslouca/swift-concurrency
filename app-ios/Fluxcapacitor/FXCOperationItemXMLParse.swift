//
//  FXCOperationItemXMLParse.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 07/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCOperationItemXMLParse: NSOperation, NSXMLParserDelegate {
    let item: FXCItem
    var element: String?
    typealias PropertyNameValueType = (propertyName: String, value: NSMutableString, type: Any)
    var xmlElement2PropertyNameValueType = [String:PropertyNameValueType]()
        
    init(item: FXCItem) {
        self.item = item
        
        // Register XML element with FXCOrder property name, initial empty value and type
        xmlElement2PropertyNameValueType["imageUrl"] = ("imageUrl", NSMutableString(), String())
        xmlElement2PropertyNameValueType["name"] = ("name", NSMutableString(), String())
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        if self.item.state != .Downloaded {
            return
        }
        
        applyParseXML(self.item)
        
        self.item.state = .XMLParsed
    }
    
    func applyParseXML(item: FXCItem) {
        let xmlParser = NSXMLParser(data: item.data!)
        xmlParser.delegate = self
        xmlParser.parse()
    }
    
    // MARK: - NSXMLParserDelegate
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        if self.cancelled {
            return
        }
        
        element = elementName
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        let tuple = xmlElement2PropertyNameValueType[element!] as PropertyNameValueType?
        if (tuple != nil){
            tuple!.value.appendString(string)
        }
    }
    
    // Sent to delegate when the parser has finished reading an element
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // If the XML parser did finish reading the element 'order' then we reached the end. We can now start filling out the FXCOrder properties.
        if elementName == "item" {
            let mirror = reflect(self.item)
            for (_, tuple) in xmlElement2PropertyNameValueType {
                for index in 0..<mirror.count {
                    let (propertyName, _) = mirror[index]
                    if propertyName == tuple.propertyName {
                        switch tuple.type {
                        case is Int:
                            self.item.setValue(tuple.value.integerValue, forKey: propertyName)
                        case is Double:
                            self.item.setValue(tuple.value.doubleValue, forKey: propertyName)
                        case is String:
                            self.item.setValue(tuple.value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: propertyName)
                        default:
                            NSLog("Uknown type")
                        }
                        
                    }
                }
                
            }
        }
    }
}