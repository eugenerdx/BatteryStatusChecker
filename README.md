# Battery status checker with a GPS Tracker

Battery status & state checker app (Code Example)

Includes: 

Objective-C code examples tested on iOS 11.0.3 & XCode 9

• UITableView updates every 30 seconds by NSTimer in Main Runloop

• Relationships between BatteryInfoManager and DatabaseWrapper based on delegate pattern

• SQLite support with DatabaseWrapper

• UIAlertController with custom UITableView inside 

	━ Custom DeleteInfoAlertController inherited from UIAlertController with UITableView (UITableViewCell from a.xib) inside.
	━ Redefined "contentViewController". The apple can reject apps with "private api usage" reason in any moment. 

• Limitless background by CLLocationManager (working only with "Always" aceppted Location sharing in iOS Settings)

  	━ Blue status bar on top are visible with "LOCATION USAGE" warning text message in the background mode
  	━ Can drain the battery for several hours backgrounding
  	━ The app can be rejected in the app store with this code usage

• Custom UITableViewCell from .xib file based on stackviews example

• KVO as observer pattern between BatteryInfoManager and ViewController

• Grand Central Dispatch with SQLite examples

• Custom headers from .xib files in storyboard and tableview reuse example

KNOWN ISSUES: 

  	━ Safe area (and iPhone X) support warnings in console with custom views from .xib files
 
Screenshots:

![alt text](https://raw.githubusercontent.com/eugenerdx/BatteryStatusChecker/master/Screenshots/Screenshot1.png "The main app viewcontroller")

![alt text](https://raw.githubusercontent.com/eugenerdx/BatteryStatusChecker/master/Screenshots/Screenshot2.png "The logging of battery statistics is started")

![alt text](https://raw.githubusercontent.com/eugenerdx/BatteryStatusChecker/master/Screenshots/Screenshot3.png "Single deletion")

![alt text](https://raw.githubusercontent.com/eugenerdx/BatteryStatusChecker/master/Screenshots/Screenshot4.png "Filtered delition")


