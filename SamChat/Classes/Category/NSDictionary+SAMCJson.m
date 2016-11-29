//
//  NSDictionary+SAMCJson.m
//  SamChat
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NSDictionary+SAMCJson.h"

@implementation NSDictionary (SAMCJson)

- (NSString *)samc_JsonString:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }
    return nil;
}

- (NSNumber *)samc_JsonNumber:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    } else if([object isKindOfClass:[NSString class]]) {
        return @([object integerValue]);
    }
    return nil;
}

@end
