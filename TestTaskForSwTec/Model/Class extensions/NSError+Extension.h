//
//  NSError+Extension.h
//  TestTaskForSwTec
//
//  Created by Eugeny on 11/2/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Extension)
- (NSError*)initErrorWithDescription:(NSString*)description withErrorCode:(NSInteger)errorCode;
@end
