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

- (NSString *)samc_JsonStringForKeyPath:(NSString *)keyPath
{
    id object = [self valueForKeyPath:keyPath];
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }
    return nil;
}

- (NSNumber *)samc_JsonNumberForKeyPath:(NSString *)keyPath
{
    id object = [self valueForKeyPath:keyPath];
    if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    } else if([object isKindOfClass:[NSString class]]) {
        return @([object integerValue]);
    }
    return nil;
}

- (NSArray *)samc_JsonArray: (NSString *)key
{
    id object = [self objectForKey:key];
    return [object isKindOfClass:[NSArray class]] ? object : nil;
    
}

- (BOOL)samc_JsonBool:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]]) {
        return [object boolValue];
    }
    return NO;
}

- (NSInteger)samc_JsonInteger:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]]) {
        return [object integerValue];
    }
    return 0;
}

@end
