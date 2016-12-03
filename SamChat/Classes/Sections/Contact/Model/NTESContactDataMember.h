//
//  NTESContactDataMember.h
//  NIM
//
//  Created by chris on 15/9/21.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESContactDefines.h"
#import "NTESGroupedContacts.h"

@interface NTESContactDataMember : NSObject<NTESContactItem,NTESGroupMemberProtocol>

@property (nonatomic,strong) NIMKitInfo *info;

@end
