//
//  SAMCMeViewController.m
//  SamChat
//
//  Created by HJ on 11/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMeViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIAlertView+NTESBlock.h"
#import "NTESNotificationCenter.h"
#import "NTESCustomNotificationDB.h"
#import "NTESCustomSysNotificationViewController.h"
#import "NTESLogManager.h"
#import "SAMCUserInfoSettingViewController.h"
#import "NTESBlackListViewController.h"
#import "NTESUserUtil.h"
#import "SAMCLogUploader.h"
#import "SAMCSPIntroViewController.h"
#import "SAMCCSAStepOneViewController.h"
#import "SAMCAccountManager.h"
#import "SAMCSettingViewController.h"

@interface SAMCMeViewController ()

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) SAMCLogUploader *logUploader;
@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@end

@implementation SAMCMeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"My Account";
    
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
    
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomNotifyChanged:) name:NTESCustomNotificationCountChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildData
{
    NSInteger customNotifyCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSString *customNotifyText  = [NSString stringWithFormat:@"自定义系统通知 (%zd)",customNotifyCount];
    
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *data = @[
                      @{
                          HeaderHeight:@(22),
                          RowContent :@[
                                  @{
                                      ExtraInfo     : uid.length ? uid : [NSNull null],
                                      CellClass     : @"SAMCSettingPortraitCell",
                                      RowHeight     : @(100),
                                      CellAction    : @"onActionTouchPortrait:",
                                      ShowAccessory : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title      :@"My QR code",
                                      ImageName  :@"ico_option_qr",
                                      CellAction :@"",
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :@"Settings",
                                      ImageName  :@"ico_option_logout",
                                      CellAction :@"onTouchSetting:",
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :@"Log out",
                                      ImageName  :@"ico_option_logout",
                                      CellAction :@"logoutCurrentAccount:",
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title     :@"Apply for SamPro",
                                      ImageName :@"ico_option_sp",
                                      CellClass :@"SAMCRightButtonCell",
                                      CellAction:@"createSamPros:",
                                      ExtraInfo :@{@"action":@"learnMore:", @"title":@"Learn More"},
                                      ShowAccessory :@(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title     :@"About SamChat",
                                      ImageName :@"ico_option_info",
                                      CellAction:@"onTouchAbout:",
                                      ShowAccessory :@(YES)
                                      },
                                  @{
                                      Title     :@"F.A.Q",
                                      ImageName :@"ico_option_help",
                                      CellAction:@"onTouchFAQ:",
                                      ShowAccessory :@(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"以下功能用于测试，请忽略",
                          RowContent :@[
                                  @{
                                      Title      :@"查看日志",
                                      CellAction :@"onTouchShowLog:",
                                      },
                                  @{
                                      Title      :@"上传日志",
                                      CellAction :@"onTouchUploadLog:",
                                      },
                                  @{
                                      Title      :@"清空所有聊天记录",
                                      CellAction :@"onTouchCleanAllChatRecord:",
                                      },
                                  @{
                                      Title      :customNotifyText,
                                      CellAction :@"onTouchCustomNotify:",
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refreshData{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - Action
- (void)onActionTouchPortrait:(id)sender
{
    SAMCUserInfoSettingViewController *vc = [[SAMCUserInfoSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchShowLog:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"查看日志" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看 DEMO 配置",@"查看 SDK 日志",@"查看网络通话日志",@"查看 Demo 日志", nil];
    [actionSheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:
                [self showDemoConfig];
                break;
            case 1:
                [self showSDKLog];
                break;
            case 2:
                [self showSDKNetCallLog];
                break;
            case 3:
                [self showDemoLog];
                break;
            default:
                break;
        }
    }];
}

- (void)onTouchUploadLog:(id)sender{
    if (_logUploader == nil) {
        _logUploader = [[SAMCLogUploader alloc] init];
    }
    
    [SVProgressHUD showWithStatus:@"正在上传" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) weakSelf = self;
    [_logUploader upload:^(NSString *urlString,NSError *error) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil && urlString) {
            [strongSelf.view makeToast:@"上传日志成功" duration:3.0 position:CSToastPositionCenter];
        } else {
            [strongSelf.view makeToast:@"上传日志失败" duration:3.0 position:CSToastPositionCenter];
        }
    }];
}

- (void)onTouchCleanAllChatRecord:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定清空所有聊天记录？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                BOOL removeRecentSession = [NTESBundleSetting sharedConfig].removeSessionWheDeleteMessages;
                [[NIMSDK sharedSDK].conversationManager deleteAllMessages:removeRecentSession];
                [self.view makeToast:@"消息已删除" duration:2 position:CSToastPositionCenter];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)onTouchCustomNotify:(id)sender{
    NTESCustomSysNotificationViewController *vc = [[NTESCustomSysNotificationViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchSetting:(id)sender
{
    SAMCSettingViewController *vc = [[SAMCSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchAbout:(id)sender
{
    SAMCWebViewController *vc = [[SAMCWebViewController alloc] initWithTitle:@"About Samchat" htmlName:@"about"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchFAQ:(id)sender
{
    SAMCWebViewController *vc = [[SAMCWebViewController alloc] initWithTitle:@"F.A.Q" htmlName:@"faq"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)logoutCurrentAccount:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"logout?" message:nil delegate:nil cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
            {
                [SVProgressHUD showWithStatus:@"logout" maskType:SVProgressHUDMaskTypeBlack];
                __weak typeof(self) wself = self;
                [[SAMCAccountManager sharedManager] logout:^(NSError * _Nullable error) {
                    [SVProgressHUD dismiss];
                    if (error) {
                        [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
                        return;
                    }
                }];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)learnMore:(id)sender
{
    SAMCSPIntroViewController *vc = [[SAMCSPIntroViewController alloc] initWithTitle:@"Become a Service Provider" htmlName:@"becomesp"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)createSamPros:(id)sender
{
    SAMCCSAStepOneViewController *vc = [[SAMCCSAStepOneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    [self buildData];
    [self.tableView reloadData];
}


- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSArray *userInfos = userInfo[NIMKitInfoKey];
    if ([userInfos containsObject:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        [self buildData];
        [self.tableView reloadData];
    }
}

#pragma mark - Private

- (void)showSDKLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showSDKNetCallLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkNetCallLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoLog{
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoConfig {
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoConfigViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

@end
