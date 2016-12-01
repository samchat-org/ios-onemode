//
//  SAMCUserInfoDB.h
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCPublicSession.h"
#import "SAMCUserManagerDelegate.h"
#import "SAMCUser.h"

@interface SAMCUserInfoDB : SAMCDBBase

- (void)addDelegate:(id<SAMCUserManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCUserManagerDelegate>)delegate;

- (SAMCUser *)userInfo:(NSString *)userId;

- (void)updateUser:(SAMCUser *)user;

- (BOOL)updateContactList:(NSArray<SAMCUserContactInfo *> *)users;

- (void)insertToContactList:(SAMCUser *)user tag:(NSString *)tag;

- (void)deleteFromContactList:(SAMCUser *)user tag:(NSString *)tag;

- (NSArray<NSString *> *)myContactListOfTag:(NSString *)tag;

- (NSString *)localContactListVersion;

- (void)updateLocalContactListVersion:(NSString *)version;

@end
