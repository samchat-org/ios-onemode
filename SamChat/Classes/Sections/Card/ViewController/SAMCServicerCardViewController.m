//
//  SAMCServicerCardViewController.m
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServicerCardViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "SAMCUserManager.h"

@interface SAMCServicerCardViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NIMCommonTableDelegate *delegator;

@end

@implementation SAMCServicerCardViewController

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    
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
    
    [self updateUser];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildData
{
    SAMCUser *user = [[SAMCUserManager sharedManager] userInfo:_userId];
    NSArray *data = @[
                      @{
                          HeaderHeight:@(22),
                          RowContent :@[
                                  @{
                                      ExtraInfo     : _userId ? _userId : [NSNull null],
                                      CellClass     : @"SAMCSettingPortraitCell",
                                      RowHeight     : @(100),
                                      ShowAccessory : @(NO)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title      :@"Chat now",
                                      ImageName  :@"ico_option_chat",
                                      CellAction :@"",
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :@"QR code",
                                      ImageName  :@"ico_option_qr",
                                      CellAction :@"",
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :@"Add to Contacts",
                                      ImageName  :@"ico_option_add",
                                      CellAction :@"touchAddToContacts:",
                                      },
                                  @{
                                      Title         : @"Follow",
                                      ImageName     : @"ico_option_follow",
                                      CellClass     : @"SAMCSwitcherCell",
                                      CellAction    : @"",
                                      ExtraInfo     : @(NO),
                                      ForbidSelect  : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title     :@"Contacts details",
                                      ImageName :@"",
                                      CellAction:@"",
                                      ShowAccessory :@(YES)
                                      },
                                  @{
                                      Title     :@"Public updates",
                                      ImageName :@"",
                                      CellAction:@"",
                                      ShowAccessory :@(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refreshData
{
    [self buildData];
    [self.tableView reloadData];
}

- (void)updateUser
{
    [[SAMCUserManager sharedManager] queryAccurateUser:_userId type:SAMCQueryAccurateUserTypeUniqueId completion:^(NSDictionary * _Nullable userDict, NSError * _Nullable error) {
        if ((error == nil) && (userDict != nil)) {
            SAMCUser *user = [SAMCUser userFromDict:userDict];
            [[SAMCUserManager sharedManager] updateUser:user];
        }
    }];
}

#pragma mark - Notification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSArray *userInfos = userInfo[NIMKitInfoKey];
    if ([userInfos containsObject:_userId]) {
        [self refreshData];
    }
}

#pragma mark - Action
- (void)touchAddToContacts:(id)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) wself = self;
    [alertController addAction: [UIAlertAction actionWithTitle:@"Add to service providers" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [wself contactAddOrRemove:YES tag:SAMC_CONTACT_TAG_SERVICE_PROVIDERS];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle:@"Add to friends list" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [wself contactAddOrRemove:YES tag:SAMC_CONTACT_TAG_FRIENDS];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];
    [self presentViewController: alertController animated: YES completion: nil];
}

#pragma mark - Private
- (void)contactAddOrRemove:(BOOL)isAdd tag:(NSString *)tag
{
    [SVProgressHUD showWithStatus:@"Adding" maskType:SVProgressHUDMaskTypeBlack];
    SAMCUser *user = [[SAMCUserManager sharedManager] userInfo:_userId];
    __weak typeof(self) wself = self;
    [[SAMCUserManager sharedManager] addOrRemove:YES contact:user tag:tag completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
        } else {
            [wself.view makeToast:@"add success" duration:2 position:CSToastPositionCenter];
        }
    }];
}

@end