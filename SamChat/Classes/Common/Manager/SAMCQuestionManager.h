//
//  SAMCQuestionManager.h
//  SamChat
//
//  Created by HJ on 8/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCQuestionManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMCQuestionManager : NSObject

+ (instancetype)sharedManager;
- (void)close;
- (void)addDelegate:(id<SAMCQuestionManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCQuestionManagerDelegate>)delegate;

- (void)sendQuestion:(NSString *)question location:(NSDictionary *)location;

- (BOOL)isMessageSending:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
