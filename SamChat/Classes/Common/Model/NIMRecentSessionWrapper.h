//
//  NIMRecentSessionWrapper.h
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMRecentSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMRecentSessionWrapper : NIMRecentSession

@property (nullable,nonatomic,copy) NIMSession *session;
@property (nullable,nonatomic,strong) NIMMessage *lastMessage;
@property (nonatomic,assign) NSInteger unreadCount;

+ (instancetype)defaultAskSamSession;

@end

NS_ASSUME_NONNULL_END