//
//  NIMAttributedLabel+SAMC.m
//  NIMKit
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "NIMAttributedLabel+SAMC.h"
#import "SAMCInputLinkParser.h"

@implementation NIMAttributedLabel (SAMC)

- (void)samc_setText:(NSString *)text
{
    [self setText:@""];
    NSArray *tokens = [[SAMCInputLinkParser currentParser] tokens:text];
    NSInteger index = 0;
    for (SAMCInputTextToken *token in tokens) {
        NSString *text = token.text;
        if (token.type == SAMCInputTokenTypeLink) {
            [self addCustomLink:token.linkData forRange:NSMakeRange(index, text.length)];
        }
        [self appendText:text];
        index += text.length;
    }
}

@end
