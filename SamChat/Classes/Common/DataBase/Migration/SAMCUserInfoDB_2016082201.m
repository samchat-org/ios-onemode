//
//  SAMCUserInfoDB_2016082201.m
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoDB_2016082201.h"
#import "SAMCDataBaseMacro.h"

@implementation SAMCUserInfoDB_2016082201

- (uint64_t)version
{
    return 2016082201;
}

- (BOOL)migrateDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    DDLogDebug(@"SAMCUserInfoDB_2016082201");
    NSArray *sqls = @[SAMC_CREATE_USERINFO_TABLE_SQL_2016082201,
                      SAMC_CREATE_USERINFO_TABLE_UNIQUE_ID_INDEX_SQL_2016082201,
                      SAMC_CREATE_USERINFO_TABLE_USERNAME_INDEX_SQL_2016082201,
                      SAMC_CREATE_CONTACT_LIST_TABLE_SQL_2016082201];
    for (NSString *sql in sqls) {
        if (![db executeUpdate:sql]) {
            DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
            if (error) {
                *error = [db lastError];
                return NO;
            }
        }
    }
    return YES;
}

@end
