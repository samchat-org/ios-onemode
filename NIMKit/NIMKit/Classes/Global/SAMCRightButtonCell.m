//
//  SAMCRightButtonCell.m
//  NIMKit
//
//  Created by HJ on 11/25/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "SAMCRightButtonCell.h"
#import "NIMCommonTableData.h"
#import "UIView+NIM.h"

@interface SAMCRightButtonCell ()

@property (nonatomic, assign) CGFloat rightPadding;

@end

@implementation SAMCRightButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _rightButton = [[SAMCCellButton alloc] initWithFrame:CGRectZero];
        _rightButton.layer.masksToBounds = YES;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _rightButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [self addSubview:_rightButton];
    }
    return self;
}

- (void)refreshData:(NIMCommonTableRow *)rowData tableView:(UITableView *)tableView{
    self.textLabel.text       = rowData.title;
    self.detailTextLabel.text = rowData.detailTitle;
    [self.rightButton setTitle:rowData.extraInfo[@"title"] forState:UIControlStateNormal];
    self.rightPadding = rowData.showAccessory ? 35 : 15;
    if (rowData.imageName) {
        self.imageView.image = [UIImage imageNamed:rowData.imageName];
    }
    NSString *subActionName      = rowData.extraInfo[@"action"];
    [self.rightButton removeTarget:self.nim_viewController action:NULL forControlEvents:UIControlEventTouchUpInside];
    if (subActionName.length) {
        SEL sel = NSSelectorFromString(subActionName);
        [self.rightButton addTarget:tableView.nim_viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.rightButton sizeToFit];
    self.rightButton.nim_right   = self.nim_width - self.rightPadding;
    self.rightButton.nim_centerY = self.nim_height * .5f;
    self.rightButton.layer.cornerRadius = self.rightButton.nim_height/2;
}

@end
