//
//  global.h
//  TestTaskForSwTec
//
//  Created by Eugeny on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#ifndef global_h
#define global_h

#pragma mark - typedefs
typedef enum
{
    EditOptionsLoad,
    EditOptionsUpdate,
    EditOptionsDeleteSingle,
    EditOptionsDeleteSomeMinutesAgo,
    EditOptionsDeleteLastInfo,
    EditOptionsDeleteFirstInfo,
    EditOptionsDeleteAll
} UpdateOptions;

#pragma mark - NSTimer & Locations update interval settings
#define kUpdateTime 30

#pragma mark - keys
#define kNeedsReloadData                       @"NeedsReloadData"
#define kTotalBatteryInformation               @"TotalBatteryInformation"
#define kCoreLocationAuthorizationStatusDenied @"CoreLocationAuthorizationStatusDenied"
#define kTimeLeft                            @"TimeRemain"

#pragma mark - integerValues
#define kOneMinute 1
#define kFiveMinutes 5

#pragma mark - UI size values
#define kDeleteTableViewCellHeight 44
#define kMainTableViewCellHeight 58

#pragma mark - Colors
#define cLightBlueColor [UIColor colorWithRed:0.152f green:0.67f blue:0.999f alpha:1.0f]
#define cClearColor [UIColor clearColor]

#define cDisabledButtonTitleColor [UIColor colorWithRed:0.8f green:0.8f blue:0.8 alpha:1.0f]
#define cTableViewSectionHeaderBackgroundColor [UIColor lightGrayColor]

#endif /* global_h */
