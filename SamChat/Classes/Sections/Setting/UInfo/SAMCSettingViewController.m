//
//  SAMCSettingViewController.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

@interface SAMCSettingViewController ()

@property (nonatomic, strong) NIMCommonTableDelegate *delegator;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy)   NSArray *data;

@end

@implementation SAMCSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
}

- (void)buildData
{
    BOOL disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title      :@"Notification",
                                      DetailTitle:disableRemoteNotification ? @"Off" : @"On",
                                      RowHeight     : @(50),
                                      ForbidSelect  : @(YES)
                                      },
                                  ],
                          FooterTitle:@"Enable or disable SamChat Notifications via \"Settings\"->\"Notifications\" on your iPhone."
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title         : @"In-App Alert Sound",
                                      CellClass     : @"SAMCSwitcherCell",
                                      RowHeight     : @(50),
                                      CellAction    : @"onActionAlertSoundChange:",
                                      ExtraInfo     : @(NO),
                                      ForbidSelect  : @(YES)
                                      },
                                  @{
                                      Title         : @"Vibrate",
                                      CellClass     : @"SAMCSwitcherCell",
                                      RowHeight     : @(50),
                                      CellAction    : @"onActionVibrateChange:",
                                      ExtraInfo     : @(YES),
                                      ForbidSelect  : @(YES)
                                      }
                                  ],
                          FooterTitle:@"Specify preference to be notified by Sound or Vibration when receiving new message."
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title      :@"Manage Storage",
                                      CellAction :@"onTouchManageStorage:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)onActionAlertSoundChange:(UISwitch *)switcher
{
}

- (void)onActionVibrateChange:(UISwitch *)switcher
{
}

- (void)onTouchManageStorage:(id)sender
{
}

@end
