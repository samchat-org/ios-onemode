//
//  NSDictionary+SAMCJson.h
//  SamChat
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SAMCJson)

- (NSString *)samc_JsonString:(NSString *)key;
- (NSNumber *)samc_JsonNumber:(NSString *)key;

- (NSString *)samc_JsonStringForKeyPath:(NSString *)keyPath;
- (NSNumber *)samc_JsonNumberForKeyPath:(NSString *)keyPath;

- (BOOL)samc_JsonBool:(NSString *)key;
@end
