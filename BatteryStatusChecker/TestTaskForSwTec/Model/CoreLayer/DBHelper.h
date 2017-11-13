//
//  DBHelper.h
//  Utils
//
//  Created by Eugeny Ulyankin on 12/03/15.
//  Copyright © 2015 eugenerdx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBHelper : NSObject

/**
 Database pre-loading
 @param dbFilename in main project bundle, will be copied to documents directory.
 @return DBHelper class
 */
- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

 /**
 Sql query execution
 The same as executeQuery;, but without a callback
 @param query "sql"
 @param block callback with execution error
 */
- (void)executeQuery:(NSString *)query withCompletion:(void (^)(NSError *error))block;

/**
 Sql query execution
 The same as executeQuery;, but without a callback
 @param query "sql"
 */
- (void)executeQuery:(NSString *)query;

/**
 Load last actual information fromdatabase
 @param query means "select" sql query
 @param block callback with error and possible result
 */
- (void)loadDataFromDB:(NSString *)query withCompletion:(void (^)(NSError *error, NSArray* result))block;

/**
 Load last actual information fromdatabase
 The same as described in loadDataFromDb (^),
 but without a callback
 In this project we are using the version with a callback.
 @param query means "select" sql query
 */
- (NSArray *)loadDataFromDB:(NSString *)query;
@end
