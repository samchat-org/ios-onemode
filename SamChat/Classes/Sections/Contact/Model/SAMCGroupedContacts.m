//
//  SAMCGroupedContacts.m
//  SamChat
//
//  Created by HJ on 9/5/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCGroupedContacts.h"
#import "NTESContactDataMember.h"
#import "SAMCUserManager.h"

@interface SAMCGroupedContacts ()

@property (nonatomic, copy) NSString *tag;

@end

@implementation SAMCGroupedContacts

// Designated initializer
- (instancetype)initWithTag:(NSString *)tag;
{
    self = [super init];
    if(self) {
        _tag = tag;
        self.groupTitleComparator = ^NSComparisonResult(NSString *title1, NSString *title2) {
            if ([title1 isEqualToString:@"#"]) {
                return NSOrderedDescending;
            }
            if ([title2 isEqualToString:@"#"]) {
                return NSOrderedAscending;
            }
            return [title1 compare:title2];
        };
        self.groupMemberComparator = ^NSComparisonResult(NSString *key1, NSString *key2) {
            return [key1 compare:key2];
        };
        [self update];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (void)update
{
    NSMutableArray *contacts = [NSMutableArray array];
    for (NSString *userId in [[SAMCUserManager sharedManager] myContactListOfTag:_tag]) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:userId];
        NTESContactDataMember *contact = [[NTESContactDataMember alloc] init];
        contact.info = info;
        [contacts addObject:contact];
    }
    [self setMembers:contacts];
}

@end
