//
//  SAMCDataBaseManager.m
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDataBaseManager.h"

@interface SAMCDataBaseManager ()


@end

@implementation SAMCDataBaseManager

+ (instancetype)sharedManager
{
    static SAMCDataBaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCDataBaseManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)open
{
    if (_userInfoDB == nil) {
        _userInfoDB = [[SAMCUserInfoDB alloc] init];
    }
    if (_publicDB == nil) {
        _publicDB = [[SAMCPublicDB alloc] init];
    }
}

- (void)close
{
    _userInfoDB = nil;
    _publicDB = nil;
}

- (BOOL)needsMigration
{
    if ([_userInfoDB needsMigration]) {
        return YES;
    }
    if ([_publicDB needsMigration]) {
        return YES;
    }
    return NO;
}

- (BOOL)doMigration
{
//    [NSThread sleepForTimeInterval:6]; // just for test
    if ([_userInfoDB needsMigration]) {
        if (![_userInfoDB doMigration]) {
            return false;
        }
    }
    if ([_publicDB needsMigration]) {
        if (![_publicDB doMigration]) {
            return false;
        }
    }
    
    return true;
}

- (void)doMigrationCompletion:(void (^)(BOOL success))completion
{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [wself doMigration];
        completion(result);
    });
}

@end
