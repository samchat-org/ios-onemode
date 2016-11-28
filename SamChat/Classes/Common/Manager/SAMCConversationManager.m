//
//  SAMCConversationManager.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConversationManager.h"

@implementation SAMCConversationManager

+ (instancetype)sharedManager
{
    static SAMCConversationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCConversationManager alloc] init];
    });
    return instance;
}

- (nullable NSArray<NIMRecentSession *> *)allChatSessions
{
    NSMutableArray *recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    return recentSessions;
}

@end
