//
//  NSError+Extension.m
//  TestTaskForSwTec
//
//  Created by Eugeny on 11/2/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "NSError+Extension.h"

@implementation NSError (Extension)
- (NSError*)initErrorWithDescription:(NSString*)description withErrorCode:(NSInteger)errorCode
{
    if (description == nil)
    {
        return nil;
    }
    
    NSDictionary *errorUserInfo = [[NSDictionary alloc] initWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
    
    self = [self initWithDomain:@"BatteryStateChecker" code:errorCode userInfo:errorUserInfo];
    return self;
}

@end
