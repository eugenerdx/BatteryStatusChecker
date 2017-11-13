//
//  BatteryInfo.h
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface BatteryInfo : NSObject

@property (assign, nonatomic, readonly) CGFloat level;
@property (assign, nonatomic, readonly) NSInteger state;
@property (assign, nonatomic, readonly) CGFloat timeStamp;
@property (strong, nonatomic, readonly) CLLocation *location;


/**
 Battery information object
 @param level of the device
 @param state of the device
 @param timeStamp current date
 @return instance of BatteryInfo
 */
- (BatteryInfo *)initWithBatteryLevel:(CGFloat)level state:(UIDeviceBatteryState)state location:(CLLocation *)location timeStamp:(CGFloat)timeStamp;
@end
