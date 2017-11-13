//
//  DataStorage.h
//  TestTaskForSwTec
//
//  Created by Eugeny on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"
#import "DBHelper.h"
#import <sqlite3.h>
#import <CoreGraphics/CoreGraphics.h>

@class DatabaseWrapper;

@protocol DatabaseWrapperDelegate <NSObject>
- (NSArray *)totalBatteryInfo;
- (NSArray *)arrayForDeletion;
@optional
- (void)databaseHasBeenLoaded:(DatabaseWrapper *)historyArray;
- (void)batteryStatisticsInDatabaseHasBeenUpdated:(DatabaseWrapper *)databaseWrapper;
@end

@interface DatabaseWrapper : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<DatabaseWrapperDelegate> delegate;
@property (nonatomic, assign, readonly) UpdateOptions updatedOptions;
@property (nonatomic, strong, readonly) NSArray *historyArray;

/**
 Synchronization between real time information and offline database
 @param options of synchronization
 */
- (void)updateDataBaseWithOptions:(UpdateOptions)options;

@end
