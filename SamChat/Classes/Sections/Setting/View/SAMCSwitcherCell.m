//
//  SAMCSwitcherCell.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSwitcherCell.h"
#import "NIMCommonTableData.h"
#import "UIView+NTES.h"

@interface SAMCSwitcherCell ()

@property(nonatomic,strong) UISwitch *switcher;

@end

@implementation SAMCSwitcherCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        _switcher.onTintColor = SAMC_COLOR_LAKE;
        [self addSubview:_switcher];
    }
    return self;
}


- (void)refreshData:(NIMCommonTableRow *)rowData tableView:(UITableView *)tableView
{
    self.textLabel.text       = rowData.title;
    self.detailTextLabel.text = rowData.detailTitle;
    if (rowData.imageName) {
        self.imageView.image = [UIImage imageNamed:rowData.imageName];
    } else {
        self.imageView.image = nil;
    }
    NSString *actionName      = rowData.cellActionName;
    [self.switcher setOn:[rowData.extraInfo boolValue] animated:NO];
    [self.switcher removeTarget:self.viewController action:NULL forControlEvents:UIControlEventValueChanged];
    if (actionName.length) {
        SEL sel = NSSelectorFromString(actionName);
        [self.switcher addTarget:tableView.viewController action:sel forControlEvents:UIControlEventValueChanged];
    }
}



#define SwitcherRight 15
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.switcher.right   = self.width - SwitcherRight;
    self.switcher.centerY = self.height * .5f;
}

@end
