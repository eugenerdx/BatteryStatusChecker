//
//  BatteryInfoManager.m
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "BatteryInfoManager.h"
#import "DatabaseWrapper.h"
#import "LocationManager.h"
#import "global.h"
#import <UIKit/UIKit.h>

@interface BatteryInfoManager () <DatabaseWrapperDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray *totalBatteryInfo;
@property (strong, nonatomic, readwrite) NSMutableArray *arrayForDeletion;
@property (strong, nonatomic) NSTimer *updateBatteryInfoTimer;
@property (strong, nonatomic) UIDevice *currentDevice;
@property (assign, nonatomic) NSInteger timeLeftCounter;

@end

@implementation BatteryInfoManager

#pragma mark - Initializers
+ (instancetype)sharedInstance
{
    static BatteryInfoManager *sharedInstance = nil;
    if (!sharedInstance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          sharedInstance = [[super allocWithZone:NULL] init];
                          BatteryInfoManager *instance = sharedInstance;
                          instance.currentDevice = [UIDevice currentDevice];
                          instance.currentDevice.batteryMonitoringEnabled = YES;
                      });
    }
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [DatabaseWrapper sharedInstance].delegate = self;
        
        if (!_totalBatteryInfo)
        {
            _totalBatteryInfo = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (dispatch_queue_t)sharedQueue
{
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedQueue = dispatch_queue_create("Battery Statistics Read/Write Queue", DISPATCH_QUEUE_CONCURRENT);
                  });
    return sharedQueue;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - KVO setup
- (NSMutableArray *)totalBatteryInfo
{
    return [self mutableArrayValueForKey:@"_totalBatteryInfo"];
}

- (void)addTotalBatteryInfoObserver:(id)object
{
    [self addObserver:object forKeyPath:@"_totalBatteryInfo.@count" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (void)removeTotalBatteryInfoObserver:(id)object
{
    [self removeObserver:object forKeyPath:@"_totalBatteryInfo.@count" context:nil];
}

#pragma mark - Main Methods
- (void)startBatteryInfoMonitoring
{
    self.timeLeftCounter = kUpdateTime+1;
    dispatch_async([BatteryInfoManager sharedQueue], ^
                   {
                       [self timerHandle];
                       
                       self.updateBatteryInfoTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer)
                                                      {
                                                          [[BatteryInfoManager sharedInstance] timerHandle];
                                                      }];
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [[NSRunLoop currentRunLoop] addTimer:self.updateBatteryInfoTimer forMode:NSRunLoopCommonModes];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kTimeLeft object:[NSNumber numberWithUnsignedInteger:self.timeLeftCounter]];
                                      });
                   });
}

- (void)stopBatteryInfoMonitoring
{
    [self.updateBatteryInfoTimer invalidate];
}

- (void)timerHandle
{
    if (self.timeLeftCounter-1 == 0)
    {
        [self currentBatteryInfo];
    }
    else
    {
        self.timeLeftCounter--;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimeLeft object:[NSNumber numberWithUnsignedInteger:self.timeLeftCounter]];
}

- (void)currentBatteryInfo
{
    UIDeviceBatteryState state = [self.currentDevice batteryState];
    CGFloat level = [self.currentDevice batteryLevel] * 100;
    CGFloat timeStemp = [[NSDate date] timeIntervalSince1970];
    BatteryInfo *batteryInfo = [[BatteryInfo alloc] initWithBatteryLevel:level state:state location:[[LocationManager sharedInstance] getLastLocation] timeStamp:timeStemp];
    dispatch_sync([BatteryInfoManager sharedQueue], ^
                  {
                      [self willChangeValueForKey:@"_totalBatteryInfo"];
                      [self.totalBatteryInfo addObject:batteryInfo];
                      [self didChangeValueForKey:@"_totalBatteryInfo"];
                      dispatch_async([BatteryInfoManager sharedQueue], ^
                                     {
                                         [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsUpdate];
                                     });
                  });
    self.timeLeftCounter = kUpdateTime;
}

- (NSArray *)getArrayForDeletion
{
    __block NSArray *array;
    
    dispatch_sync([BatteryInfoManager sharedQueue], ^
                  {
                      array = [self.arrayForDeletion copy];
                  });
    return array;
}

- (void)cleanArrayForDeletion
{
    dispatch_sync([BatteryInfoManager sharedQueue], ^
                  {
                      self.arrayForDeletion = nil;
                      if (!self.arrayForDeletion)
                      {
                          self.arrayForDeletion = [[NSMutableArray alloc] init];
                      }
                  });
}

#pragma mark - Database actions
- (void)deleteBatteryInfo:(BatteryInfo *)batteryInfo
{
    dispatch_sync([BatteryInfoManager sharedQueue], ^
                  {
                      [self cleanArrayForDeletion];
                      [self.arrayForDeletion addObject:batteryInfo];
                      [self.totalBatteryInfo removeObject:batteryInfo];
                      [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsDeleteSingle];
                  });
}

- (void)deleteNitems:(NSInteger)itemIndex withOptions:(UpdateOptions)options
{
    [self cleanArrayForDeletion];
    
    if (options == EditOptionsDeleteFirstInfo)
    {
        for (NSInteger i = self.totalBatteryInfo.count - itemIndex - 1; i < self.totalBatteryInfo.count; i++)
        {
            [self.arrayForDeletion addObject:[self.totalBatteryInfo objectAtIndex:i]];
        }
        [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsDeleteFirstInfo];
    }
    else if (options == EditOptionsDeleteLastInfo)
    {
        for (NSInteger i=0; i < self.totalBatteryInfo.count; i++)
        {
            if (i < itemIndex - 1)
            {
                [self.arrayForDeletion addObject:[self.totalBatteryInfo objectAtIndex:i]];
            }
        }
        [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsDeleteLastInfo];
    }
    else if (options == EditOptionsDeleteAll)
    {
        [self.totalBatteryInfo removeAllObjects];
        [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsDeleteAll];
    }
}

- (void)deleteBatteryInfoSomeMinutesAgo:(NSInteger)someMinutesAgo withOptions:(UpdateOptions)options
{
    NSDate *earlierDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute value:-someMinutesAgo toDate:[NSDate date] options:0];
    
    [self cleanArrayForDeletion];
    
    for (BatteryInfo *info in self.totalBatteryInfo)
    {
        NSDate *dateByTimeStamp = [NSDate dateWithTimeIntervalSince1970:info.timeStamp];
        if ([self date:dateByTimeStamp isBetweenDate:earlierDate andDate:[NSDate date]])
        {
            [self.arrayForDeletion addObject:info];
        }
    }
    [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsDeleteSomeMinutesAgo];
}

- (void)loadHistory
{
    [[DatabaseWrapper sharedInstance] updateDataBaseWithOptions:EditOptionsLoad];
}

#pragma mark - Data storage delegate
- (void)databaseHasBeenLoaded:(DatabaseWrapper *)historyArray;
{
    dispatch_sync([BatteryInfoManager sharedQueue], ^
                  {
                      [self currentBatteryInfo];
                      [self willChangeValueForKey:@"_totalBatteryInfo"];
                      self.totalBatteryInfo = [historyArray.historyArray mutableCopy];
                      [self didChangeValueForKey:@"_totalBatteryInfo"];
                  });
}

- (void)batteryStatisticsInDatabaseHasBeenUpdated:(DatabaseWrapper*)databaseWrapper
{
    if (databaseWrapper.updatedOptions == EditOptionsDeleteLastInfo ||
        databaseWrapper.updatedOptions == EditOptionsDeleteFirstInfo ||
        databaseWrapper.updatedOptions == EditOptionsDeleteSomeMinutesAgo)
    {
        [self willChangeValueForKey:@"_totalBatteryInfo"];
        self.totalBatteryInfo = [databaseWrapper.historyArray mutableCopy];
        [self didChangeValueForKey:@"_totalBatteryInfo"];
    }
    
    if (self.arrayForDeletion.count > 0)
    {
        [self cleanArrayForDeletion];
    }
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    return YES;
}
@end

