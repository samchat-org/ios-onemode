//
//  SAMCInputLinkParser.m
//  NIMKit
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "SAMCInputLinkParser.h"

@implementation SAMCInputTextToken
@end

@interface SAMCInputLinkParser ()
@property (nonatomic,strong) NSCache *tokens;
@end


@implementation SAMCInputLinkParser
+ (instancetype)currentParser
{
    static SAMCInputLinkParser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCInputLinkParser alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _tokens = [[NSCache alloc] init];
    }
    return self;
}

- (NSArray *)tokens:(NSString *)text
{
    NSArray *tokens = nil;
    if ([text length]) {
        tokens = [_tokens objectForKey:text];
        if (tokens == nil) {
            tokens = [self parseToken:text];
            [_tokens setObject:tokens
                        forKey:text];
        }
    }
    return tokens;
}

- (NSArray *)parseToken:(NSString *)text
{
    NSMutableArray *tokens = [NSMutableArray array];
    
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*)\\]\\(samchat:\\/\\/(.*)\\)"
                                                                         options:0
                                                                           error:nil];
    __block NSInteger index = 0;
    [exp enumerateMatchesInString:text
                          options:0
                            range:NSMakeRange(0, [text length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [text substringWithRange:result.range];
//                           NSLog(@"SAMCInputLinkParser parseToken: %@", rangeText);
                           if (result.range.location > index) {
                               NSString *rawText = [text substringWithRange:NSMakeRange(index, result.range.location - index)];
                               SAMCInputTextToken *token = [[SAMCInputTextToken alloc] init];
                               token.type = SAMCInputTokenTypeText;
                               token.text = rawText;
                               [tokens addObject:token];
                           }
                           SAMCInputTextToken *token = [[SAMCInputTextToken alloc] init];
                           token.type = SAMCInputTokenTypeLink;
                           token.text = rangeText;
                           
                           NSRange range = [rangeText rangeOfString:@"](samchat:"];
                           if (range.location != NSNotFound) {
                               token.text = [rangeText substringWithRange:NSMakeRange(1, range.location-1)];
                               token.linkData = [rangeText substringWithRange:NSMakeRange(range.location+2, rangeText.length-range.location-3)];
//                               NSLog(@"text:%@, linkData:%@", token.text, token.linkData);
                           }
                           
                           [tokens addObject:token];
                           index = result.range.location + result.range.length;
                       }];
    
    if (index < [text length]) {
        NSString *rawText = [text substringWithRange:NSMakeRange(index, [text length] - index)];
        SAMCInputTextToken *token = [[SAMCInputTextToken alloc] init];
        token.type = SAMCInputTokenTypeText;
        token.text = rawText;
        [tokens addObject:token];
    }
    return tokens;
}

@end
