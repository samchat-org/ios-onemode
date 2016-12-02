//
//  SAMCNavigationDropDownMenu.m
//  PFNavigationDropdownMenu
//
//  Created by HJ on 12/2/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "SAMCNavigationDropDownMenu.h"
#import "UIView+NIM.h"

@interface SAMCNavigationDropDownMenu()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIView *tableContainerView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIImageView *menuArrow;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign) BOOL isShown;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation SAMCNavigationDropDownMenu

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items
                selectedIndex:(NSInteger)index
                   titleColor:(UIColor *)titleColor
                containerView:(UIView *)containerView;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableContainerView = containerView;
        self.cellHeight = 44;
        self.animationDuration = 0.5;
        self.isShown = NO;
        self.items = items;
        self.isAnimating = NO;
        self.selectedIndex = index;
        
        NSString *title = items[index];
        self.menuButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.menuButton setTitle:title forState:UIControlStateNormal];
        self.menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [self.menuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.menuButton];
        
        self.menuArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_arrow_down"]];
        [self.menuButton addSubview:self.menuArrow];
        
        CGRect tableViewFrame = CGRectMake(0, 0, containerView.frame.size.width, (CGFloat)(self.items.count) * self.cellHeight);
        self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = SAMC_COLOR_INGRABLUE;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.menuArrow sizeToFit];
    self.menuButton.contentEdgeInsets = UIEdgeInsetsMake(5, self.menuArrow.nim_width+7, 5, self.menuArrow.nim_width+7);
    [self.menuButton sizeToFit];
    self.menuButton.nim_centerX = self.nim_width/2;
    self.menuButton.nim_centerY = self.nim_height/2;
    self.menuArrow.nim_right = self.menuButton.nim_width;
    self.menuArrow.nim_centerY = self.menuButton.nim_height/2;
}

- (void)showMenu
{
    if (self.isShown) {
        return;
    }
    [self.tableContainerView addSubview:self.tableView];
    self.tableView.nim_origin = CGPointMake(self.tableView.nim_origin.x, -(CGFloat)(self.items.count) * self.cellHeight);
    [UIView animateWithDuration:self.animationDuration
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         self.tableView.nim_origin = CGPointMake(self.tableView.nim_origin.x, 0);
                         self.menuArrow.transform = CGAffineTransformRotate(self.menuArrow.transform, 180 * (CGFloat)(M_PI / 180));
                     }
                     completion:^(BOOL finished) {
                         self.isShown = YES;
                         self.isAnimating = NO;
                         [self.menuButton setTitle:self.items[self.selectedIndex] forState:UIControlStateNormal];
                         [self setNeedsLayout];
                     }];
}

- (void)hideMenu
{
    if (self.isShown == NO) {
        return;
    }
    [UIView animateWithDuration:self.animationDuration
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.tableView.nim_origin = CGPointMake(self.tableView.nim_origin.x, -(CGFloat)(self.items.count) * self.cellHeight);
                         self.menuArrow.transform = CGAffineTransformRotate(self.menuArrow.transform, 180 * (CGFloat)(M_PI / 180));
                     } completion:^(BOOL finished) {
                         [self.tableView removeFromSuperview];
                         self.isShown = NO;
                         self.isAnimating = NO;
                         [self.menuButton setTitle:self.items[self.selectedIndex] forState:UIControlStateNormal];
                         [self setNeedsLayout];
                     }];
}

- (void)menuButtonTapped:(UIButton *)sender
{
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    if (self.isShown) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SAMCNavigationDropDownCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = self.items[indexPath.row];
        cell.tintColor = [UIColor whiteColor];
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = SAMC_COLOR_INGRABLUE_HINT;
    }
    
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.backgroundColor = SAMC_COLOR_INGRABLUE_HINT;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = SAMC_COLOR_INGRABLUE;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = SAMC_COLOR_INGRABLUE_HINT;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = SAMC_COLOR_INGRABLUE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    self.didSelectItemAtIndexHandler(indexPath.row);
    [self hideMenu];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = SAMC_COLOR_INGRABLUE;
}

@end
