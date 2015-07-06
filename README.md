# swift-concurrency
This project illustrates how one can concurrently perform operations in iOS with the 
NSOperation and NSOperationQueue classes.

### Scenario
This scenario implemented can be part of a grocery delivery system like Instacart, where users
place orders (not implemented here) for groceries to be delivered to them at given 
address and time. These orders can then be viewed by couriers registered with the system
that can pick and carry out an order. This project implements the part of such a system
needed by a courier that wants an overview of orders in a region.

An order contains the following information:
- Delivery address
- Time and date for the delivery to take place
- Items (onion, broccoli, etc) and quantity of each item
- Price offered by the person placing the order to a potential courier
- Other information such as currency, etc

The sample scenario that is being implemented here is fetching a list of orders from a server 
and display the orders in a UITableView. The user (courier) can then select an order from the table view 
to view further details for that order.

### Implementation
For the sake of consistency and in order to avoid any misconception, the items included in an order
can only be chosen from a predefined list of possible items that the system will offer. Each item
has a name and an image. An item can easily be extended to contain additional information like weight, 
price, etc. Since the list of possible items is predefined, it makes sense to load them from the server
as soon as the app starts in order to avoid lacking and user waiting time later. The list of items consists
of three items: Broccoli, Onion, Pumpkin.

The list of items is a property list that contains an item ID as a key and a String value holding the 
URL pointing to the items's details:
```xml
<plist version="1.0">
	<dict>
		<key>1</key>
		<string>http://lucaslouca.com/item-1.xml</string>
		<key>2</key>
		<string>http://lucaslouca.com/item-2.xml</string>
		<key>3</key>
		<string>http://lucaslouca.com/item-3.xml</string>
	</dict>
</plist>
```
Once we have fetched the list of items we start downloading each individual item's details from the provided  URL
and load them into an in-memory dictionary that the app can access later when it needs information 
about a certain item. The item's details are represented in XML form. For instance, the item located at
http://lucaslouca.com/item-3.xml looks as follows:
<item>
	<name>Pumpkin</name>
	<imageUrl>http://lucaslouca.com/item-3.png</imageUrl>
</item>

Note that the fetching of the items list, the download of an item's details XML, the parsing of the XML and the download of the
item's image are all separate operations performed in the background to provide concurrency.

The next step is to fetch a list of orders from a server when the user taps a button and fill
the table view. For the sake of simplicity, the list will be a property list as well, that contains an
order ID as a key and a String value holding the URL pointing to the order's details:
<plist version="1.0">
	<dict>
		<key>1</key>
		<string>http://lucaslouca.com/order-1.xml</string>
		<key>2</key>
		<string>http://lucaslouca.com/order-2.xml</string>
		<key>3</key>
		<string>http://lucaslouca.com/order-3.xml</string>
	</dict>
</plist>

When the list download is complete, the first step is to populate the table view 
with the orders. These orders do not contain all their details yet. Once the meta information
of an order is displayed in the table view  - at this point only the information that there exists an order - 
the download of the order's details is started. The order details are in XML form and have the following structure:
<order>
	<title>Need groceries</title>
	<info>Lorem ipsum</info>
	<price>15</price>
	<currency>USD</currency>
	<itemCount>3</itemCount>
	<deliveryDate>May, 15th 16:00</deliveryDate>
	<location>
		<address>33-07 Ditmars Blvd, Queens, NY 11105, United States</address>
		<radius>1</radius>
		<radiusUnit>km</radiusUnit>
		<latitude>51.50007773</latitude>
		<longitude>-0.1246402</longitude>
	</location>
	<items>
		<item>
			<id>1</id>
			<quantity>5</quantity>
			<quantityUnit>kg</quantityUnit>
		</item>
		<item>
			<id>2</id>
			<quantity>3</quantity>
			<quantityUnit>pc.</quantityUnit>
		</item>
	</items>
</order>

While the order details are being downloaded and the XML being parsed, we display an activity indicator
in the order's table view cell accessory view. Again, the fetching of the order list, the download and parsing of the 
order's XML is done using separate operations in the background to provide concurrency and a responsive application
flow. 

To make the app even more responsive, when the user scrolls down the list of orders, any operations of order
rows that are not visible any more will be cancelled and the processing of the newly visible orders is started. This
makes sense because we want to display the user order details about the orders that are currently visible in
the table view.

Once an order is completely downloaded and processed, the user can select the order from the table view to view
the order's details. This is done by navigating (segue) to a separate view which displays a map containing the
delivery location as well as a list of items and additional information about the order (date and time of delivery, etc).

### Additional features
In addition to the above implementation for fetching, parsing and displaying orders in a table view, this
app features also stuff like pull to refresh, table view filtering, parallax UITableView header views and
some fancy icons :-)


