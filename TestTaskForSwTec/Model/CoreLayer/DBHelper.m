//
//  DBHelper.h
//  Utils
//
//  Created by Eugeny Ulyankin on 12/03/15.
//  Copyright © 2015 eugenerdx. All rights reserved.
//

#import "DBHelper.h"
#import "NSError+Extension.h"
#import "BatteryInfoManager.h"

@interface DBHelper()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) NSMutableArray *columnNamesArray;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

@end

@implementation DBHelper

- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename
{
    self = [super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilename = dbFilename;
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

- (void)copyDatabaseIntoDocumentsDirectory
{
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
    {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        if (error != nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable withCompletion:(void (^)(NSError *error))block
{
    sqlite3 *sqlite3Database;
    NSError *error = nil;
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (self.resultsArray)
    {
        [self.resultsArray removeAllObjects];
        self.resultsArray = nil;
    }
    self.resultsArray = [[NSMutableArray alloc] init];
    
    if (self.columnNamesArray)
    {
        [self.columnNamesArray removeAllObjects];
        self.columnNamesArray = nil;
    }
    self.columnNamesArray = [[NSMutableArray alloc] init];
    
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if (openDatabaseResult == SQLITE_OK)
    {
        sqlite3_stmt *compiledStatement;
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if (prepareStatementResult == SQLITE_OK)
        {
            if (!queryExecutable)
            {
                NSMutableArray *rowDataArray;
                while (sqlite3_step(compiledStatement) == SQLITE_ROW)
                {
                    rowDataArray = [[NSMutableArray alloc] init];
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    for (int i=0; i < totalColumns; i++)
                    {
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        if (dbDataAsChars != NULL)
                        {
                            [rowDataArray addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        if (self.columnNamesArray.count != totalColumns)
                        {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.columnNamesArray addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    if (rowDataArray.count > 0)
                    {
                        [self.resultsArray addObject:rowDataArray];
                    }
                }
            }
            else
            {
                int executeQueryResults = sqlite3_step(compiledStatement);
                
                if (executeQueryResults == SQLITE_DONE)
                {
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else
                {
                    error = [[NSError alloc] initErrorWithDescription:[NSString stringWithFormat:@"%s", sqlite3_errmsg(sqlite3Database)] withErrorCode:(NSInteger)executeQueryResults];
                }
            }
        }
        else
        {
            error = [[NSError alloc] initErrorWithDescription:[NSString stringWithFormat:@"%s", sqlite3_errmsg(sqlite3Database)] withErrorCode:(NSInteger)prepareStatementResult];
        }
        sqlite3_finalize(compiledStatement);
    }
    else
    {
        error = [[NSError alloc] initErrorWithDescription:[NSString stringWithFormat:@"%s", sqlite3_errmsg(sqlite3Database)] withErrorCode:(NSInteger)openDatabaseResult];
        block(error);
    }
    sqlite3_close(sqlite3Database);
    
    if (block)
    {
        block(error);
    }
}

- (void)loadDataFromDB:(NSString *)query withCompletion:(void (^)(NSError *error, NSArray* result))block
{
    dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_TIME_NOW), ^
                          {
                              [self runQuery:[query UTF8String] isQueryExecutable:NO withCompletion:^(NSError *error)
                               {
                                   block(error, [self.resultsArray copy]);
                               }];
                          });
}

- (void)executeQuery:(NSString *)query withCompletion:(void (^)(NSError *error))block
{
    dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_TIME_NOW), ^
                          {
                              [self runQuery:[query UTF8String] isQueryExecutable:YES withCompletion:^(NSError *error)
                               {
                                   if (block)
                                   {
                                       block(error);
                                   }
                                   
                               }];
                          });
}

- (NSArray *)loadDataFromDB:(NSString *)query
{
    [self runQuery:[query UTF8String] isQueryExecutable:NO withCompletion:^(NSError *error) {}];
    return (NSArray *)self.resultsArray;
}

- (void)executeQuery:(NSString *)query
{
    [self runQuery:[query UTF8String] isQueryExecutable:YES withCompletion:^(NSError *error){}];
}
@end


