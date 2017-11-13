//
//  BatteryInfo.m
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "BatteryInfo.h"
#import "global.h"

@interface BatteryInfo ()

@property (assign, nonatomic, readwrite) CGFloat level;
@property (assign, nonatomic, readwrite) NSInteger state;
@property (assign, nonatomic, readwrite) CGFloat timeStamp;
@property (strong, nonatomic, readwrite) CLLocation *location;


@end

@implementation BatteryInfo

- (BatteryInfo *)initWithBatteryLevel:(CGFloat)level state:(UIDeviceBatteryState)state location:(CLLocation *)location timeStamp:(CGFloat)timeStamp
{
    self = [super init];
    if (self)
    {
        _level = level;
        _state = state;
        _location = location;
        _timeStamp = timeStamp;
    }
    return self;
}
@end
