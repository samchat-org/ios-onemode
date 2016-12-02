//
//  SAMCPublicSearchResultCell.m
//  SamChat
//
//  Created by HJ on 10/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSearchResultCell.h"
#import "SAMCAvatarImageView.h"

@interface SAMCPublicSearchResultCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation SAMCPublicSearchResultCell

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
    [self addSubview:self.followButton];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(10);
        make.top.equalTo(self).with.offset(5);
        make.bottom.equalTo(self).with.offset(-5);
        make.width.equalTo(self.avatarView.mas_height);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(20);
        make.bottom.equalTo(self.mas_centerY);
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).with.offset(10);
        make.right.equalTo(self).with.offset(-10);
        make.centerY.equalTo(self);
    }];
    
    [self.categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.top.equalTo(self.mas_centerY);
        make.right.equalTo(self.followButton.mas_left);
    }];

    [_followButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_followButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setUser:(SAMCUser *)user
{
    _user = user;
    _nameLabel.text = user.userInfo.username;
    _categoryLabel.text = user.userInfo.spInfo.serviceCategory;
    
    NSURL *url = user.userInfo.avatar ? [NSURL URLWithString:user.userInfo.avatar] : nil;
    [_avatarView samc_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_user"] options:SDWebImageRetryFailed];
}

- (void)setIsFollowed:(BOOL)isFollowed
{
    _isFollowed = isFollowed;
    [_followButton setTitle:isFollowed?@"Unfollow":@"Follow" forState:UIControlStateNormal];
    [_followButton setTitleColor:isFollowed?SAMCUIColorFromRGB(0xA2AEBC):SAMCUIColorFromRGB(0x2676B6) forState:UIControlStateNormal];
//    [_followButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}

#pragma mark - Action
- (void)onOperate:(id)sender
{
    self.followButton.enabled = false;
    __weak typeof(self) wself = self;
    [self.delegate follow:!_isFollowed user:_user completion:^(BOOL success) {
        if (success) {
            self.isFollowed = !_isFollowed;
        }
        wself.followButton.enabled = YES;
    }];
}

#pragma mark - lazy load
- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] initWithFrame:CGRectZero circleWidth:0.0f];
        _avatarView.circleColor = SAMCUIColorFromRGB(0xD8DCE2);
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _nameLabel.textColor = SAMCUIColorFromRGB(0x13243F);
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.font = [UIFont systemFontOfSize:15.0f];
        _categoryLabel.textColor = SAMCUIColorFromRGB(0x4F606D);
    }
    return _categoryLabel;
}

- (UIButton *)followButton
{
    if (_followButton == nil) {
        _followButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_followButton addTarget:self action:@selector(onOperate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

@end
