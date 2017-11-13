//
//  NSString+Extension.m
//  TestTaskForSwTec
//
//  Created by Eugeny on 11/5/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "NSString+Extension.h"
#import <UIKit/UIKit.h>

@implementation NSString (Extension)

+ (instancetype)humanFriendlyDateAsStringByTimeStamp:(CGFloat)timeStamp;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
}

+ (instancetype)batteryStateAsString:(NSInteger)batteryState
{
    switch (batteryState)
    {
        case UIDeviceBatteryStateUnknown:
            return @"Unknown";
            break;
        case UIDeviceBatteryStateUnplugged:
            return @"Unplugged";
            break;
        case UIDeviceBatteryStateCharging:
            return @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            return @"Full";
            break;
        default:
            break;
    }
    return @"";
}
@end
