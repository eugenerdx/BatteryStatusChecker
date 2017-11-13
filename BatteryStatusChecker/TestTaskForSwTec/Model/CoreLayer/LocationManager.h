//
//  LocationManager.h
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>
+ (instancetype)sharedInstance;


/**
 Get last location
 @return CLLocation object
 */
- (CLLocation *)getLastLocation;

/**
 Request permission alert
 */
- (void)requestPermissions;

/**
 Start updating location and get long time working
 in the background. 
 */
- (void)startLocationUpdates;

/**
 Stop updating location
 */
- (void)stopLocationUpdates;

@end
