//
//  SAMCStateDateInfo.m
//  SamChat
//
//  Created by HJ on 9/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCStateDateInfo.h"
#import "SAMCServerAPIMacro.h"
#import "NSDictionary+SAMCJson.h"

@implementation SAMCStateDateInfo

+ (instancetype)stateDateInfoFromDict:(NSDictionary *)dict
{
    SAMCStateDateInfo *info = [[SAMCStateDateInfo alloc] init];
    info.servicerListVersion = [dict samc_JsonString:SAMC_SERVICER_LIST];
    info.customerListVersion = [dict samc_JsonString:SAMC_CUSTOMER_LIST];
    info.followListVersion = [dict samc_JsonString:SAMC_FOLLOW_LIST];
    return info;
}

@end
