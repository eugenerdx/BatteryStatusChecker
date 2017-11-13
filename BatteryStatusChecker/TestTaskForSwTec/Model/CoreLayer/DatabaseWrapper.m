//
//  DataStorage.m
//  TestTaskForSwTec
//
//  Created by Eugeny on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "DatabaseWrapper.h"
#import "BatteryInfoManager.h"
#import "DBHelper.h"

@interface DatabaseWrapper ()

@property (nonatomic, strong, readwrite) NSArray *historyArray;
@property (nonatomic, assign, readwrite) UpdateOptions updatedOptions;
@property (nonatomic, strong) DBHelper *dbHelper;

@end

@implementation DatabaseWrapper

#pragma mark - Initializers
+ (instancetype)sharedInstance
{
    static DatabaseWrapper *sharedInstance = nil;
    if (!sharedInstance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] init];
            [sharedInstance activateDatabase];
        });
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Database action handlers
- (void)updateDataBaseWithOptions:(UpdateOptions)options
{
    [self setUpdatedOptions:options];
    
    if (options == EditOptionsLoad)
        [self loadHistoryFromDatabase];
    else if (options == EditOptionsUpdate)
        [self updateDatabase];
    else if (options == EditOptionsDeleteAll)
    {
        [self deleteAllBatteryInfo];
        [self.delegate batteryStatisticsInDatabaseHasBeenUpdated:self];
    }
    else if ((options == EditOptionsDeleteLastInfo) || (options == EditOptionsDeleteFirstInfo) || (options == EditOptionsDeleteSomeMinutesAgo) || options == EditOptionsDeleteSingle)
    {
        NSArray *arrayForDeletion = [self.delegate arrayForDeletion];
        BOOL success = NO;
        
        for(BatteryInfo *info in arrayForDeletion)
        {
            success = [self deleteObjectByTimeStamp:info.timeStamp];
        }
        
        if (success)
        {
            [self setHistoryArray:[self loadAllBatteryInfo]];
            [self.delegate batteryStatisticsInDatabaseHasBeenUpdated:self];
        }
    }
}

- (void)updateDatabase
{
    NSArray *temporaryArray = [[self.delegate totalBatteryInfo] copy];
    
    dispatch_group_t group = dispatch_group_create();
    if ([temporaryArray count] > 0)
    {
        dispatch_group_enter(group);
        for (NSInteger i = 0; i < [temporaryArray count]; i++)
        {
            BatteryInfo *batteryInfo = [temporaryArray objectAtIndex:i];
            [self updateBatteryInfo:batteryInfo AtIndex:i];
        }
        [self setHistoryArray:[temporaryArray copy]];
        dispatch_group_leave(group);
    }
    dispatch_group_wait(group,  DISPATCH_TIME_FOREVER);
    
    [self.delegate batteryStatisticsInDatabaseHasBeenUpdated:self];
}

- (void)loadHistoryFromDatabase
{
    NSMutableArray *db = [[self loadAllBatteryInfo] mutableCopy];
    
    if ([db count] > 0)
        [self setHistoryArray:[NSArray arrayWithArray:db]];
    else
        [self setHistoryArray:[self.delegate totalBatteryInfo]];
    
    [self.delegate databaseHasBeenLoaded:self];
}

#pragma mark - SQLite
- (void)activateDatabase
{
    self.dbHelper = [[DBHelper alloc] initWithDatabaseFilename:@"batteryinfo.db"];
    self.historyArray = [[NSArray alloc] init];
}

- (void)updateBatteryInfo:(BatteryInfo *)batteryInfo AtIndex:(NSInteger)index
{
    NSString *query = [NSString stringWithFormat:@"insert or replace into batteryInfoDetails values(\"%ld\", \"%s\", \"%s\", \"%s\", \"%f\")", (long)index,
                       [[NSString stringWithFormat:@"%f", batteryInfo.level] cStringUsingEncoding:NSUTF8StringEncoding],
                       [[NSString stringWithFormat:@"%ld", (long)batteryInfo.state] cStringUsingEncoding:NSUTF8StringEncoding],
                       [[NSString stringWithFormat:@"%f/%f", batteryInfo.location.coordinate.latitude,
                         batteryInfo.location.coordinate.longitude] cStringUsingEncoding:NSUTF8StringEncoding],
                       batteryInfo.timeStamp];
    
    [self.dbHelper executeQuery:query withCompletion:^(NSError *error)
     {
         if (error)
             NSLog(@"error");
     }];
}

- (NSArray *)loadAllBatteryInfo
{
    __block NSMutableArray *loadedDatabaseArray = [[NSMutableArray alloc] init];
    
    NSString *query = @"select * from batteryInfoDetails";
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self.dbHelper loadDataFromDB:query withCompletion:^(NSError *error, NSArray *result)
     {
         if (!error)
         {
             for (NSArray *array in result)
             {
                 CGFloat level = .0f;
                 CGFloat timeStamp = .0f;
                 NSInteger state = 0;
                 NSString *stringLocation = @"";
                 
                 for (int i=0; i < [array count]; i++)
                 {
                     level = [NSString stringWithUTF8String:[[array objectAtIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]].floatValue;
                     state = [NSString stringWithUTF8String:[[array objectAtIndex:2] cStringUsingEncoding:NSUTF8StringEncoding]].intValue;
                     timeStamp = [NSString stringWithUTF8String:[[array objectAtIndex:4] cStringUsingEncoding:NSUTF8StringEncoding]].doubleValue;
                     stringLocation = [NSString stringWithUTF8String:[[array objectAtIndex:3] cStringUsingEncoding:NSUTF8StringEncoding]];
                 }
                 
                 CGFloat parseLatitude = [stringLocation componentsSeparatedByString:@"/"].firstObject.doubleValue;
                 CGFloat parseLongtitude = [stringLocation componentsSeparatedByString:@"/"].lastObject.doubleValue;
                 CLLocation *unwrappedLocation = [[CLLocation alloc] initWithLatitude:parseLatitude longitude:parseLongtitude];
                 
                 BatteryInfo *batteryInfo = [[BatteryInfo alloc] initWithBatteryLevel:level state:state location:unwrappedLocation timeStamp:timeStamp];
                 
                 [loadedDatabaseArray addObject:batteryInfo];
             }
         }
         else
         {
             NSLog(@"%@", error);
         }
         dispatch_group_leave(group);
     }];
    return [loadedDatabaseArray copy];
}

- (BOOL)deleteAllBatteryInfo
{
    __block BOOL success = NO;
    
    NSString *query = @"delete from batteryInfoDetails";
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self.dbHelper executeQuery:query withCompletion:^(NSError *error)
     {
         if (!error)
         {
             [self setHistoryArray:[self loadAllBatteryInfo]];
             success = YES;
         }
         dispatch_group_leave(group);
     }];
    dispatch_group_wait(group,  DISPATCH_TIME_FOREVER);
    
    return success;
}

- (BOOL)deleteObjectByTimeStamp:(CGFloat)timestamp
{
    __block BOOL success = NO;
    
    NSString *query = [NSString stringWithFormat: @"delete from batteryInfoDetails where timeStamp like \"%f\"", (double)timestamp];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self.dbHelper executeQuery:query withCompletion:^(NSError *error)
     {
         if (!error)
         {
             [self setHistoryArray:[self loadAllBatteryInfo]];
             success = YES;
         }
         dispatch_group_leave(group);
     }];
    dispatch_group_wait(group,  DISPATCH_TIME_FOREVER);
    
    return success;
}
@end
