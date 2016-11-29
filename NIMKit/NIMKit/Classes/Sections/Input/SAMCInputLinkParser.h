//
//  SAMCInputLinkParser.h
//  NIMKit
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SAMCInputTokenType) {
    SAMCInputTokenTypeText,
    SAMCInputTokenTypeLink,
};

@interface SAMCInputTextToken : NSObject
@property (nonatomic,copy) NSString *text;
@property (nonatomic,strong) id linkData;
@property (nonatomic,assign) SAMCInputTokenType type;
@end

@interface SAMCInputLinkParser : NSObject
+ (instancetype)currentParser;
- (NSArray *)tokens:(NSString *)text;
@end
