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
