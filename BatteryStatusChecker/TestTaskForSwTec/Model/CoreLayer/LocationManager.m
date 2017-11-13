//
//  LocationManager.m
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//
#import "LocationManager.h"
#import "global.h"

@interface LocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDate *lastTimestamp;
@property (nonatomic, strong, readwrite) CLLocation* lastLocation;

@end

@implementation LocationManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance =  [[super allocWithZone:NULL] init];
        LocationManager *instance = sharedInstance;
        instance.locationManager = [[CLLocationManager alloc] init];
        instance.locationManager.delegate = instance;
        instance.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        instance.locationManager.pausesLocationUpdatesAutomatically = NO;
    });
    return sharedInstance;
}

- (void)requestPermissions
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCoreLocationAuthorizationStatusDenied object:nil];
    }
    else
    {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
        {
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        }
        if ([self.locationManager respondsToSelector:@selector(setShowsBackgroundLocationIndicator:)])
        {
            if (@available(iOS 11.0, *))
            {
                [self.locationManager setShowsBackgroundLocationIndicator:YES];
            }
        }
    }
}

- (void)startLocationUpdates
{
    [self.locationManager startUpdatingLocation];
    [self setLastLocation:[self getLastLocation]];
}

- (CLLocation *)getLastLocation
{
    return [self locationManager].location;
}

- (void)stopLocationUpdates
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCoreLocationAuthorizationStatusDenied object:nil];
    }
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval interval = self.lastTimestamp ? [now timeIntervalSinceDate:self.lastTimestamp] : 0;
    
    if (![self lastTimestamp] || interval >= kUpdateTime)
    {
        [self setLastTimestamp:now];
    }
    [self setLastLocation:[locations lastObject]];
}

@end
