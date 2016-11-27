//
//  SAMCSettingPortraitCell.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingPortraitCell.h"
#import "NIMCommonTableData.h"
#import "UIView+NTES.h"
#import "NTESSessionUtil.h"
#import "SAMCAvatarImageView.h"

@interface SAMCSettingPortraitCell()

@property (nonatomic,strong) SAMCAvatarImageView *avatar;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UILabel *accountLabel;

@end

@implementation SAMCSettingPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat avatarWidth = 55.f;
        _avatar = [[SAMCAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, avatarWidth, avatarWidth)];
        [self addSubview:_avatar];
        _nameLabel      = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
        [self addSubview:_nameLabel];
        _accountLabel   = [[UILabel alloc] initWithFrame:CGRectZero];
        _accountLabel.font = [UIFont systemFontOfSize:14.f];
        _accountLabel.textColor = [UIColor grayColor];
        [self addSubview:_accountLabel];
    }
    return self;
}

- (void)refreshData:(NIMCommonTableRow *)rowData tableView:(UITableView *)tableView{
    self.textLabel.text       = rowData.title;
    self.detailTextLabel.text = rowData.detailTitle;
    NSString *uid = rowData.extraInfo;
    if ([uid isKindOfClass:[NSString class]]) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid];
        self.nameLabel.text   = info.showName ;
        [self.nameLabel sizeToFit];
        NSString *samchatId = info.samchatId;
        self.accountLabel.text = [samchatId length] ? [NSString stringWithFormat:@"SamChat ID: %@", samchatId] : @"";
        [self.accountLabel sizeToFit];
        [self.avatar samc_setImageWithURL:[NSURL URLWithString:info.avatarUrlString] placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
    }
}


#define AvatarLeft 30
#define TitleAndAvatarSpacing 12
#define TitleTop 22
#define AccountBottom 22

- (void)layoutSubviews{
    [super layoutSubviews];
    self.avatar.left    = AvatarLeft;
    self.avatar.centerY = self.height * .5f;
    self.nameLabel.left = self.avatar.right + TitleAndAvatarSpacing;
    self.nameLabel.top  = TitleTop;
    self.accountLabel.left    = self.nameLabel.left;
    self.accountLabel.bottom  = self.height - AccountBottom;
}

@end
