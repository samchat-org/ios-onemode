//
//  NIMRecentSessionWrapper.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMRecentSessionWrapper.h"
#import "NTESSessionMsgConverter.h"

@implementation NIMRecentSessionWrapper

@synthesize session = _session;
@synthesize lastMessage = _lastMessage;
@synthesize unreadCount = _unreadCount;

- (NIMSession *)session
{
    return _session;
}

- (void)setSession:(NIMSession *)session
{
    _session = session;
}

- (NIMMessage *)lastMessage
{
    return _lastMessage;
}

- (void)setLastMessage:(NIMMessage *)lastMessage
{
    _lastMessage = lastMessage;
}

- (NSInteger)unreadCount
{
    return _unreadCount;
}

- (void)setUnreadCount:(NSInteger)unreadCount
{
    _unreadCount = unreadCount;
}

+ (instancetype)defaultAskSamSession
{
    NIMRecentSessionWrapper *recent = [[NIMRecentSessionWrapper alloc] init];
    recent.session = [NIMSession session:SAMC_SAMCHAT_ACCOUNT_ASKSAM type:NIMSessionTypeP2P];
    recent.lastMessage = [NTESSessionMsgConverter msgWithText:@"What service do you need today?"];
    recent.unreadCount = 0;
    return recent;
}

@end
