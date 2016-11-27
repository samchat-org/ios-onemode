//
//  SAMCSettingAvatarView.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingAvatarView.h"
#import "SAMCAvatarImageView.h"

@interface SAMCSettingAvatarView ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;

@end

@implementation SAMCSettingAvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.avatarView = [[SAMCAvatarImageView alloc] init];
    [self addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(20);
        make.bottom.equalTo(self).with.offset(-20);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.equalTo(self.avatarView.mas_height);
    }];
}

- (void)refreshData:(NIMKitInfo *)info
{
    [self.avatarView samc_setImageWithURL:[NSURL URLWithString:info.avatarUrlString] placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
}

@end
