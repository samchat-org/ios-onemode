//
//  SAMCUser.m
//  SamChat
//
//  Created by HJ on 9/6/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUser.h"
#import "SAMCServerAPIMacro.h"
#import "NSDictionary+SAMCJson.h"

@implementation SAMCUser

+ (instancetype)userFromDict:(NSDictionary *)userDict
{
    SAMCUser *user = [[SAMCUser alloc] init];
    user.userId = [userDict samc_JsonString:SAMC_ID];
    
    SAMCUserInfo *info = [[SAMCUserInfo alloc] init];
    info.username = [userDict samc_JsonString:SAMC_USERNAME];
    info.samchatId = [userDict samc_JsonString:SAMC_SAMCHAT_ID];
    info.countryCode = [userDict samc_JsonString:SAMC_COUNTRYCODE];;
    info.cellPhone = [userDict samc_JsonString:SAMC_CELLPHONE];
    info.email = [userDict samc_JsonString:SAMC_EMAIL];
    info.address = [userDict samc_JsonString:SAMC_ADDRESS];
    info.usertype = [userDict samc_JsonNumber:SAMC_TYPE];
    info.avatar = [userDict samc_JsonStringForKeyPath:SAMC_AVATAR_THUMB];
    info.avatarOriginal = [userDict samc_JsonStringForKeyPath:SAMC_AVATAR_ORIGIN];
    info.lastupdate = [userDict samc_JsonNumber:SAMC_LASTUPDATE];
    info.spInfo = [SAMCSamProsInfo spInfoFromDict:userDict[SAMC_SAM_PROS_INFO]];
    
    user.userInfo = info;
    return user;
}

- (SAMCSPBasicInfo *)spBasicInfo
{
    return [SAMCSPBasicInfo infoOfUser:_userId
                              username:_userInfo.username
                                avatar:_userInfo.avatar
                              blockTag:NO
                          favouriteTag:NO
                              category:_userInfo.spInfo.serviceCategory];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\ruserId:%@\rusername:%@",[super description],_userId,_userInfo.username];
}

@end

@implementation SAMCUserInfo

@end

@implementation SAMCSamProsInfo

+ (instancetype)spInfoFromDict:(NSDictionary *)spInfoDict
{
    SAMCSamProsInfo *info = [[SAMCSamProsInfo alloc] init];
    info.companyName = [spInfoDict samc_JsonString:SAMC_COMPANY_NAME];
    info.serviceCategory = [spInfoDict samc_JsonString:SAMC_SERVICE_CATEGORY];
    info.serviceDescription = [spInfoDict samc_JsonString:SAMC_SERVICE_DESCRIPTION];
    info.countryCode = [spInfoDict samc_JsonString:SAMC_COUNTRYCODE];
    info.phone = [spInfoDict samc_JsonString:SAMC_PHONE];
    info.email = [spInfoDict samc_JsonString:SAMC_EMAIL];
    info.address = [spInfoDict samc_JsonString:SAMC_ADDRESS];
    return info;
}

@end
