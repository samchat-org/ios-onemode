//
//  SAMCPublicViewController.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicViewController.h"
#import "SAMCAccountManager.h"
#import "SAMCPublicSearchViewController.h"

@implementation SAMCPublicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Public";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self setUpNavItem];
}

- (void)setUpNavItem
{
    NSString *imageNormal;
    NSString *imageHighlighted;
    if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
        imageNormal = @"ico_nav_add_dark";
        imageHighlighted = @"ico_nav_add_dark_pressed";
    } else {
        imageNormal = @"ico_nav_add_light";
        imageHighlighted = @"ico_nav_add_light_pressed";
    }
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn addTarget:self action:@selector(searchPublic:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:imageNormal] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:imageHighlighted] forState:UIControlStateHighlighted];
    [addBtn sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)searchPublic:(id)sender
{
    SAMCPublicSearchViewController *vc = [[SAMCPublicSearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
