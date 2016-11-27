//
//  SAMCSettingAvatarView.h
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCAvatarImageView.h"

@interface SAMCSettingAvatarView : UIView

@property (nonatomic, strong, readonly) SAMCAvatarImageView *avatarView;
- (void)refreshData:(NIMKitInfo *)info;

@end
