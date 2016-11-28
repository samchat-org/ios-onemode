//
//  SAMCAskSamSessionConfig.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAskSamSessionConfig.h"

@implementation SAMCAskSamSessionConfig

- (NSArray<NSNumber *> *)inputBarItemTypes
{
    return @[@(NIMInputBarItemTypeTextAndRecord)];
}

- (NSArray *)mediaItems
{
    return nil;
}

- (id<NIMKitMessageProvider>)messageDataProvider
{
    return nil;
}

- (NSInteger)maxInputLength
{
    return 200;
}

- (NSString *)inputViewPlaceholder
{
    return @"What service do you need today?";
}

- (id<NIMCellLayoutConfig>)layoutConfigWithMessage:(NIMMessage *)message
{
    id<NIMCellLayoutConfig> config;
    switch (message.messageType) {
        default:
            //其他类型的Cell采用默认实现就返回nil即可。
            break;
    }
    return config;
}

- (BOOL)shouldHandleReceipt
{
    return NO;
}

@end
