//
//  SAMCPreferenceManager.h
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCStateDateInfo.h"

@interface SAMCLoginData : NSObject<NSCoding>
@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *token;

- (NSString *)finalToken;
@end

@interface SAMCPreLoginInfo : NSObject<NSCoding>
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *cellPhone;
@property (nonatomic, copy) NSString *avatarUrl;
@end

@interface SAMCPreferenceManager : NSObject

@property (nonatomic, strong) NSNumber *currentUserMode;

@property (nonatomic, strong) SAMCLoginData *loginData;

@property (nonatomic, strong) NSNumber *needQuestionNotify;
@property (nonatomic, strong) NSNumber *needSound;
@property (nonatomic, strong) NSNumber *needVibrate;

@property (nonatomic, strong) NSNumber *advRecallTimeMinute;

@property (nonatomic, strong) SAMCPreLoginInfo *preLoginInfo;

+ (instancetype)sharedManager;
- (void)reset;

@end
