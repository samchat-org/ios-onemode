//
//  SAMCUserInfoDB.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoDB.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCUserInfoDB_2016082201.h"
#import "SAMCDataBaseMacro.h"
#import "GCDMulticastDelegate.h"

@interface SAMCUserInfoDB ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCUserManagerDelegate> *multicastDelegate;

// cache
@property (nonatomic, strong) NSMutableDictionary *userInfoCache;
@property (nonatomic, strong) NSMutableArray *servicerList;
@property (nonatomic, strong) NSMutableArray *customerList;
@property (nonatomic, copy) NSString *localContactListVersion;
@property (nonatomic, copy) NSString *localCustomerListVersion;

@end

@implementation SAMCUserInfoDB

- (instancetype)init
{
    self = [super initWithName:@"userinfo.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
}

- (void)addDelegate:(id<SAMCUserManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<SAMCUserManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCUserManagerDelegate> *)multicastDelegate
{
    if (_multicastDelegate == nil) {
        _multicastDelegate = (GCDMulticastDelegate <SAMCUserManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _multicastDelegate;
}

#pragma mark - Create DB
- (void)createMigrationInfo
{
    self.migrationManager = [SAMCMigrationManager managerWithDatabaseQueue:self.queue];
    NSArray *migrations = @[[SAMCUserInfoDB_2016082201 new]];
    [self.migrationManager addMigrations:migrations];
    if (![self.migrationManager hasMigrationsTable]) {
        [self.migrationManager createMigrationsTable:NULL];
    }
}

- (SAMCUser *)userInfoInDB:(NSString *)userId
{
    __block SAMCUser *user = [[SAMCUser alloc] init];
    user.userId = userId;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM userInfo WHERE unique_id = ?", userId];
        if ([s next]) {
            SAMCUserInfo *userInfo = [[SAMCUserInfo alloc] init];
            userInfo.username = [s stringForColumn:@"username"];
            userInfo.samchatId = [s stringForColumn:@"samchat_id"];
            userInfo.usertype = @([s intForColumn:@"usertype"]);
            userInfo.lastupdate = @([s longForColumn:@"lastupdate"]);
            userInfo.avatar = [s stringForColumn:@"avatar"];
            userInfo.avatarOriginal = [s stringForColumn:@"avatar_original"];
            userInfo.countryCode = [s stringForColumn:@"countrycode"];
            userInfo.cellPhone = [s stringForColumn:@"cellphone"];
            userInfo.email = [s stringForColumn:@"email"];
            userInfo.address = [s stringForColumn:@"address"];
            if ([userInfo.usertype isEqual:@(SAMCuserTypeSamPros)]) {
                SAMCSamProsInfo *spInfo = [[SAMCSamProsInfo alloc] init];
                spInfo.companyName = [s stringForColumn:@"sp_company_name"];
                spInfo.serviceCategory = [s stringForColumn:@"sp_service_category"];
                spInfo.serviceDescription = [s stringForColumn:@"sp_service_description"];
                spInfo.countryCode = [s stringForColumn:@"sp_countrycode"];
                spInfo.phone = [s stringForColumn:@"sp_phone"];
                spInfo.address = [s stringForColumn:@"sp_address"];
                spInfo.email = [s stringForColumn:@"sp_email"];
                userInfo.spInfo = spInfo;
            }
            user.userInfo = userInfo;
        }
        [s close];
    }];
    return user;
}

- (void)updateUserInDB:(SAMCUser *)user
{
    DDLogDebug(@"updateUser: %@", user);
    if (user.userId == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    NSString *unique_id = user.userId;
    SAMCUserInfo *userInfo = user.userInfo;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM userinfo WHERE unique_id = ?", unique_id];
        
        NSString *username = userInfo.username;
        NSString *samchat_id = userInfo.samchatId;
        NSString *countrycode = userInfo.countryCode;
        NSString *cellphone = userInfo.cellPhone;
        NSString *email = userInfo.email;
        NSString *address = userInfo.address;
        NSNumber *usertype = userInfo.usertype;
        NSString *avatar = userInfo.avatar;
        NSString *avatar_original = userInfo.avatarOriginal;
        NSNumber *lastupdate = userInfo.lastupdate;
        NSString *sp_company_name = userInfo.spInfo.companyName;
        NSString *sp_service_category = userInfo.spInfo.serviceCategory;
        NSString *sp_service_description = userInfo.spInfo.serviceDescription;
        NSString *sp_countrycode = userInfo.spInfo.countryCode;
        NSString *sp_phone = userInfo.spInfo.phone;
        NSString *sp_address = userInfo.spInfo.address;
        NSString *sp_email = userInfo.spInfo.email;
        
        if ([s next]) {
            username = username ?:[s stringForColumn:@"username"];
            samchat_id = samchat_id ?:[s stringForColumn:@"samchat_id"];
            countrycode = countrycode ?:[s stringForColumn:@"countrycode"];
            cellphone = cellphone ?:[s stringForColumn:@"cellphone"];
            email = email ?:[s stringForColumn:@"email"];
            address = address ?:[s stringForColumn:@"address"];
            usertype = usertype ?:@([s intForColumn:@"usertype"]);
            avatar = avatar ?:[s stringForColumn:@"avatar"];
            avatar_original = avatar_original ?:[s stringForColumn:@"avatar_original"];
            lastupdate = lastupdate ?:@([s longForColumn:@"lastupdate"]);
            sp_company_name = sp_company_name ?:[s stringForColumn:@"sp_company_name"];
            sp_service_category = sp_service_category ?:[s stringForColumn:@"sp_service_category"];
            sp_service_description = sp_service_description ?:[s stringForColumn:@"sp_service_description"];
            sp_countrycode = sp_countrycode ?:[s stringForColumn:@"sp_countrycode"];
            sp_phone = sp_phone ?:[s stringForColumn:@"sp_phone"];
            sp_address = sp_address ?:[s stringForColumn:@"sp_address"];
            sp_email = sp_email ?:[s stringForColumn:@"sp_email"];
            [db executeUpdate:@"UPDATE userinfo SET username=?, samchat_id=?, usertype=?, lastupdate=?, avatar=?, avatar_original=?, countrycode=?, \
             cellphone=?, email=?, address=?, sp_company_name=?, sp_service_category=?, sp_service_description=?, \
             sp_countrycode=?, sp_phone=?, sp_address=?, sp_email=? WHERE unique_id = ?", username, samchat_id, usertype, lastupdate, avatar, avatar_original,
             countrycode, cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode,
             sp_phone, sp_address, sp_email, unique_id];
        } else {
            [db executeUpdate:@"INSERT INTO userinfo(unique_id, username, samchat_id, usertype, lastupdate, avatar, avatar_original, countrycode, \
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address, sp_email) \
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", unique_id, username, samchat_id, usertype, lastupdate, avatar, avatar_original, countrycode,
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address, sp_email];
        }
        [s close];
    }];
}

- (BOOL)updateContactListInDB:(NSArray<SAMCUserContactInfo *> *)users
{
    DDLogDebug(@"updateContactListInDB:%@", users);
    if (![self resetContactListTable]) {
        return NO;
    }
    if ([users count] == 0) {
        return true;
    }
    // TODO: separate transaction?
    __block BOOL result = YES;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SAMCUserContactInfo *info in users) {
            NSString *uniqueId = info.userId;
            NSString *username = info.username;
            NSNumber *usertype = info.usertype;
            NSNumber *lastupdate = info.lastupdate;
            NSString *avatar = info.avatar;
            NSString *spServiceCategory = info.serviceCategory;
            FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM userinfo WHERE unique_id = ?", info.userId];
            if ([s next] && ([s intForColumnIndex:0]>0)) {
                result = [db executeUpdate:@"UPDATE userinfo SET username=?, usertype=?, lastupdate=?, avatar=?, sp_service_category=? WHERE unique_id=?",username,usertype,lastupdate,avatar,spServiceCategory,uniqueId];
            } else {
                result = [db executeUpdate:@"INSERT INTO userinfo(unique_id, username, usertype, lastupdate, avatar, sp_service_category) VALUES (?,?,?,?,?,?)", uniqueId,username,usertype,lastupdate,avatar,spServiceCategory];
            }
            [s close];
            if (result == NO) {
                *rollback = YES;
                break;
            }
            for (NSString *tag in info.tags) {
                result = [db executeUpdate:@"INSERT INTO contact_list(unique_id, tag) VALUES(?,?)",uniqueId,tag];
                if (result == NO) {
                    *rollback = YES;
                    break;
                }
            }
        }
    }];
    if (result) {
        [self.multicastDelegate didUpdateContactList];
    }
    return result;
}

- (void)insertToContactListInDB:(SAMCUser *)user tag:(NSString *)tag
{
    if ((user == nil) || (tag == nil)) {
        DDLogError(@"insertToContactList:%@, tag:%@ error", user, tag);
        return;
    }
    [self updateUser:user];
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM contact_list WHERE unique_id=? AND tag=?", user.userId, tag];
        if ([s next] && ([s intForColumnIndex:0]>0)) {
        } else {
            [db executeUpdate:@"INSERT INTO contact_list(unique_id, tag) VALUES(?,?)",user.userId,tag];
            [wself.multicastDelegate didAddContact:user tag:tag];
        }
        [s close];
    }];
}

- (void)deleteFromContactListInDB:(SAMCUser *)user tag:(NSString *)tag
{
    if ((user == nil) || (tag == nil)) {
        DDLogError(@"deleteFromContactList:%@, tag:%@ error", user, tag);
        return;
    }
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM contact_list WHERE unique_id=? AND tag=?", user.userId, tag];
        [wself.multicastDelegate didRemoveContact:user tag:tag];
    }];
}

- (NSArray<NSString *> *)myContactListOfTagInDB:(NSString *)tag
{
    __block NSMutableArray *contactList = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT unique_id FROM contact_list where tag=?", tag];
        while ([s next]) {
            NSString *uniqueId = [s stringForColumnIndex:0];
            [contactList addObject:uniqueId];
        }
        [s close];
    }];
    return contactList;
}

- (NSString *)localContactListVersionInDB
{
    __block NSString *contactListVersion = @"0";
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT version FROM contact_list_version WHERE type=0"];
        if([s next]) {
            contactListVersion = [s stringForColumnIndex:0];
        }
        [s close];
    }];
    DDLogDebug(@"local contact list version: %@", contactListVersion);
    return contactListVersion;
}

- (void)updateLocalContactListVersionInDB:(NSString *)version
{
    if (version == nil) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"REPLACE INTO contact_list_version(type, version) VALUES (0,?)", version];
    }];
}

#pragma mark - Private
- (BOOL)resetContactListTable
{
    __block BOOL result = YES;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls;
        sqls = @[@"DROP TABLE IF EXISTS contact_list",
                 SAMC_CREATE_CONTACT_LIST_TABLE_SQL_2016082201];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
                result = NO;
            }
        }
    }];
    return result;
}

#pragma mark - Public
- (SAMCUser *)userInfo:(NSString *)userId
{
    SAMCUser *user = [self.userInfoCache objectForKey:userId];
    if (user) {
        return user;
    }
    user = [self userInfoInDB:userId];
    if (user) {
        [self.userInfoCache setObject:user forKey:user.userId];
    }
    return user;
}

- (void)updateUser:(SAMCUser *)user
{
    [self updateUserInDB:user];
    // user may not have all info
    // so update cache from db
    user = [self userInfoInDB:user.userId];
    if (user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userInfoCache setObject:user forKey:user.userId];
        });
    }
}

- (NSArray<NSString *> *)myContactListOfTag:(NSString *)tag
{
    NSArray *contactList;
//    if (listType == SAMCContactListTypeServicer) {
//        contactList = self.servicerList;
//    } else {
//        contactList = self.customerList;
//    }
//    if (contactList) {
//        return contactList;
//    }
    contactList = [self myContactListOfTagInDB:tag];
//    if (contactList) {
//        if (listType == SAMCContactListTypeServicer) {
//            self.servicerList = [contactList mutableCopy];
//        } else {
//            self.customerList = [contactList mutableCopy];
//        }
//    }
    return contactList;
}

- (BOOL)updateContactList:(NSArray<SAMCUserContactInfo *> *)users
{
    BOOL result = [self updateContactListInDB:users];
//    if (result) {
//        NSArray *contactList = [self myContactList];
//        if (contactList) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (listType == SAMCContactListTypeServicer) {
//                    self.servicerList = [contactList mutableCopy];
//                } else {
//                    self.customerList = [contactList mutableCopy];
//                }
//            });
//        }
//    }
    return result;
}

- (void)insertToContactList:(SAMCUser *)user tag:(NSString *)tag
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (listType == SAMCContactListTypeServicer) {
//            [self.servicerList addObject:user.userId];
//        } else {
//            [self.customerList addObject:user.userId];;
//        }
//    });
    [self insertToContactListInDB:user tag:tag];
}

- (void)deleteFromContactList:(SAMCUser *)user tag:(NSString *)tag
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (listType == SAMCContactListTypeServicer) {
//            [self.servicerList removeObject:user.userId];
//        } else {
//            [self.customerList removeObject:user.userId];;
//        }
//    });
    [self deleteFromContactListInDB:user tag:tag];
}

- (NSString *)localContactListVersion
{
    if (_localContactListVersion) {
        return _localContactListVersion;
    }
    _localContactListVersion = [self localContactListVersionInDB];
    return _localContactListVersion;
}

- (void)updateLocalContactListVersion:(NSString *)version
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _localContactListVersion = version;
    });
    [self updateLocalContactListVersionInDB:version];
}

#pragma mark - lazy load
- (NSMutableDictionary *)userInfoCache
{
    if (_userInfoCache == nil) {
        _userInfoCache = [[NSMutableDictionary alloc] init];
    }
    return _userInfoCache;
}

@end
