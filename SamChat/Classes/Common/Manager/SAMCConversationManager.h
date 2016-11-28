//
//  SAMCConversationManager.h
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SAMCConversationManager : NSObject

+ (instancetype)sharedManager;

- (nullable NSArray<NIMRecentSession *> *)allChatSessions;

@end

NS_ASSUME_NONNULL_END