//
//  SAMCQuestion.h
//  SamChat
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCQuestion : NSObject

@property (nonatomic, strong) NSNumber *datetime;
@property (nonatomic, strong) NSNumber *questionId;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *fromUser;

+ (instancetype)questionFromDict:(NSDictionary *)questionDict;

@end