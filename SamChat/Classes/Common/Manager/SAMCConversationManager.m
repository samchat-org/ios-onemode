//
//  SAMCConversationManager.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConversationManager.h"
#import "NIMRecentSessionWrapper.h"

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
    NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
    NSMutableArray *chatSessions = [[NSMutableArray alloc] init];
    NIMRecentSession *askSamSession;
    for (NIMRecentSession *recentSession in recentSessions) {
        if ([recentSession.session.sessionId hasPrefix:SAMC_PUBLIC_ACCOUNT_PREFIX]) {
            continue;
        }
        if ([recentSession.session.sessionId isEqualToString:SAMC_SAMCHAT_ACCOUNT_ASKSAM]) {
            askSamSession = recentSession;
        }
        [chatSessions addObject:recentSession];
    }
    if (askSamSession == nil) {
        NIMRecentSessionWrapper *askSamSession = [NIMRecentSessionWrapper defaultAskSamSession];
        [chatSessions insertObject:askSamSession atIndex:0];
    } else {
        [chatSessions removeObject:askSamSession];
        [chatSessions insertObject:askSamSession atIndex:0];
    }
    return chatSessions;
}

@end
