//
//  SAMCSPInfoSettingViewController.m
//  SamChat
//
//  Created by HJ on 12/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPInfoSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SAMCAccountManager.h"

@interface SAMCSPInfoSettingViewController ()

@property (nonatomic, strong) NIMCommonTableDelegate *delegator;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy)   NSArray *data;

@end

@implementation SAMCSPInfoSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"SamPro Setting";
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoHasUpdatedNotification:)
                                                 name:NIMKitUserInfoHasUpdatedNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildData
{
}

- (void)refresh
{
    [self buildData];
    [self.tableView reloadData];
}

#pragma mark - onUserInfoHasUpdatedNotification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSArray *userInfos = userInfo[NIMKitInfoKey];
    if ([userInfos containsObject:[SAMCAccountManager sharedManager].currentAccount]) {
        [self refresh];
    }
}

@end
