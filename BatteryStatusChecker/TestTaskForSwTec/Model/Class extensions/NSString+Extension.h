//
//  NSString+Extension.h
//  TestTaskForSwTec
//
//  Created by Eugeny on 11/5/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (Extension)

+ (instancetype)humanFriendlyDateAsStringByTimeStamp:(CGFloat)timeStamp;
+ (instancetype)batteryStateAsString:(NSInteger)batteryState;
@end
