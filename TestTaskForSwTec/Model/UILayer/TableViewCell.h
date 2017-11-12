//
//  TableViewCell.h
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface TableViewCell : UITableViewCell

/**
 Battery information for each instance
 @param level of the charge
 @param state (ex. charging, unknown, charged, etc.)
 @param timeStamp in CGFloat value
 @param location coordinate with latitude and longtitude
 */
- (void)cellWithBatteryLevel:(CGFloat)level state:(UIDeviceBatteryState)state timeStamp:(CGFloat)timeStamp location:(CLLocation *)location;

/**
 Set visibility of all labels in Custom TableViewCell
 You need set it YES, if you want to see the labels
 @param enabled  Default set to NO
 */
- (void)setVisibleActualBatteryInfo:(BOOL)enabled;

/**
 Set visibility of GPS coordinates labels in Custom TableViewCell
 @param enabled  Default set to NO
 */
- (void)setVisibleGpsCoordinates:(BOOL)enabled;
@end
