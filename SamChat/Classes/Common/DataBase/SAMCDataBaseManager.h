//
//  SAMCDataBaseManager.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCUserInfoDB.h"
#import "SAMCPublicDB.h"

@interface SAMCDataBaseManager : NSObject

@property (nonatomic, strong) SAMCUserInfoDB *userInfoDB;
@property (nonatomic, strong) SAMCPublicDB *publicDB;

+ (instancetype)sharedManager;
- (void)open;
- (void)close;
- (BOOL)needsMigration;
- (BOOL)doMigration;

- (void)doMigrationCompletion:(void (^)(BOOL success))completion;

@end
