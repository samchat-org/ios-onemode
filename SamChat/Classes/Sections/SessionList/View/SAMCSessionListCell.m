//
//  SAMCSessionListCell.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSessionListCell.h"
#import "SAMCAvatarImageView.h"
#import "NIMKitUtil.h"
#import "NIMBadgeView.h"
#import "UIView+NIM.h"
#import "NIMMessage+SAMC.h"
#import "SAMCAccountManager.h"

@interface SAMCSessionListCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NIMBadgeView *badgeView;
@property (nonatomic, strong) UIImageView *muteImageView;

@end

@implementation SAMCSessionListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.categoryLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.messageLabel];
    [self addSubview:self.badgeView];
    [self addSubview:self.muteImageView];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(10);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.top.equalTo(self).with.offset(15);
    }];

    [self.categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).with.offset(5);
        make.bottom.equalTo(self.nameLabel);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.categoryLabel.mas_right).with.offset(5);
        make.right.equalTo(self).with.offset(-10);
        make.bottom.equalTo(self.nameLabel);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.bottom.equalTo(self).with.offset(-15);
    }];
    
    [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.messageLabel.mas_right).with.offset(5);
        make.right.equalTo(self).with.offset(-10);
        make.centerY.equalTo(self.messageLabel);
    }];
    
    [_nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_categoryLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_categoryLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_messageLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_muteImageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_muteImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _badgeView.nim_right = _avatarView.nim_right + 6.0f;
    _badgeView.nim_top = _avatarView.nim_top - 6.0f;
}

- (void)setRecentSession:(NIMRecentSession *)recentSession
{
    if ([recentSession.session.sessionId hasPrefix:SAMC_SAMCHAT_ACCOUNT_PREFIX]) {
        self.nameLabel.textColor = SAMC_COLOR_LAKE;
        self.avatarView.isRounded = NO;
    } else {
        self.nameLabel.textColor = SAMC_COLOR_INK;
        self.avatarView.isRounded = YES;
    }
    
    NSString *lastMessageContent = [recentSession.lastMessage messageContent];
    self.messageLabel.text = [lastMessageContent length] ? lastMessageContent : @" ";
    self.timeLabel.text = [self timestampDescriptionForRecentSession:recentSession];
    
    NIMKitInfo *info = nil;
    if (recentSession.session.sessionType == NIMSessionTypeTeam) {
        info = [[NIMKit sharedKit] infoByTeam:recentSession.session.sessionId];
    } else {
        info = [[NIMKit sharedKit] infoByUser:recentSession.session.sessionId
                                    inSession:recentSession.session];
    }
    
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    [self.avatarView samc_setImageWithURL:url placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
    
    self.categoryLabel.text = info.serviceCategory;
    if (recentSession.unreadCount) {
        self.badgeView.hidden = NO;
        self.badgeView.badgeValue = [@(recentSession.unreadCount) stringValue];
    } else {
        self.badgeView.hidden = YES;
        self.badgeView.badgeValue = @"";
    }
    
    NSString *name = @"";
    if (recentSession.session.sessionType == NIMSessionTypeP2P) {
        if ([recentSession.session.sessionId isEqualToString:[SAMCAccountManager sharedManager].currentAccount]) {
            name = @"Me";
        } else {
            name = info.showName;
        }
    }else{
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recentSession.session.sessionId];
        name = team.teamName;
    }
    self.nameLabel.text = [name length] ? name : @" ";
    
    BOOL needNotify;
    if (recentSession.session.sessionType == NIMSessionTypeP2P) {
        needNotify = [[NIMSDK sharedSDK].userManager notifyForNewMsg:recentSession.session.sessionId];
    } else {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recentSession.session.sessionId];
        needNotify = [team notifyForNewMsg];
    }
    self.muteImageView.hidden = needNotify;
    self.muteImageView.image = needNotify?nil:[UIImage imageNamed:@"ico_chat_mute"];
}

- (NSString *)timestampDescriptionForRecentSession:(NIMRecentSession *)recent
{
    return [NIMKitUtil showTime:recent.lastMessage.timestamp showDetail:NO];
}

#pragma mark - lazy load
- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] init];
        _avatarView.userInteractionEnabled = false;
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _nameLabel.textColor = SAMC_COLOR_INK;
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.font = [UIFont systemFontOfSize:13.0f];
        _categoryLabel.textColor = SAMC_COLOR_INK;
    }
    return _categoryLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textColor = SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UILabel *)messageLabel
{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:15.0f];
        _messageLabel.textColor = SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
    }
    return _messageLabel;
}

- (NIMBadgeView *)badgeView
{
    if (_badgeView == nil) {
        _badgeView = [NIMBadgeView viewWithBadgeTip:@""];
    }
    return _badgeView;
}

- (UIImageView *)muteImageView
{
    if (_muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] init];
    }
    return _muteImageView;
}

@end
