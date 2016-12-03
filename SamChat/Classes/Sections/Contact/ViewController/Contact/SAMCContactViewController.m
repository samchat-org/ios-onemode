//
//  SAMCContactViewController.m
//  SamChat
//
//  Created by HJ on 12/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCContactViewController.h"
#import "NTESSessionUtil.h"
#import "NTESSessionViewController.h"
#import "NTESContactUtilItem.h"
#import "NTESContactDefines.h"
#import "SAMCGroupedContacts.h"
#import "UIView+Toast.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESSearchTeamViewController.h"
#import "NTESContactAddFriendViewController.h"
#import "NTESPersonalCardViewController.h"
#import "UIAlertView+NTESBlock.h"
#import "SVProgressHUD.h"
#import "NTESContactUtilCell.h"
#import "NIMContactDataCell.h"
#import "NIMContactSelectViewController.h"
#import "NTESUserUtil.h"
#import "SAMCNavigationDropDownMenu.h"
#import "SAMCAccountManager.h"
#import "SAMCUserManager.h"

@interface SAMCContactViewController () <UITableViewDataSource, UITableViewDelegate, NIMSystemNotificationManagerDelegate, NTESContactUtilCellDelegate, NIMContactDataCellDelegate, NIMLoginManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) SAMCGroupedContacts *contacts;

@property (nonatomic, strong) NSString *currentContactTag;
@property (nonatomic, strong) NSArray *contactTags;

@end

@implementation SAMCContactViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *arrowImageName;
    if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
        arrowImageName = @"ico_arrow_down_dark";
        _contactTags = @[SAMC_CONTACT_TAG_ALL,
                         SAMC_CONTACT_TAG_CUSTOMERS,
                         SAMC_CONTACT_TAG_FRIENDS,
                         SAMC_CONTACT_TAG_SERVICE_PROVIDERS,
                         SAMC_CONTACT_TAG_ASSOCIATE_SPS];
    } else {
        arrowImageName = @"ico_arrow_down_light";
        _contactTags = @[SAMC_CONTACT_TAG_ALL,
                         SAMC_CONTACT_TAG_CUSTOMERS,
                         SAMC_CONTACT_TAG_FRIENDS];
    }
    NSInteger selectedIndex = 0;
    self.currentContactTag = _contactTags[selectedIndex];
    SAMCNavigationDropDownMenu *menuView = [[SAMCNavigationDropDownMenu alloc] initWithFrame:CGRectMake(0, 0, 200, 44)
                                                                                       items:_contactTags
                                                                               selectedIndex:selectedIndex
                                                                                  titleColor:SAMC_BarTitleColor
                                                                              arrowImageName:arrowImageName
                                                                               containerView:self.view];
    __weak typeof(self) wself = self;
    menuView.didSelectItemAtIndexHandler = ^(NSInteger index){
        wself.currentContactTag = wself.contactTags[index];
        [wself refresh];
    };
    self.navigationItem.titleView = menuView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserBlackListHasUpdatedNotification object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self prepareData];
    [[[NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [tapRec setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tapRec];
}

- (void)setUpNavItem{
    UIButton *teamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [teamBtn addTarget:self action:@selector(onOpera:) forControlEvents:UIControlEventTouchUpInside];
    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_normal"] forState:UIControlStateNormal];
    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
    [teamBtn sizeToFit];
    UIBarButtonItem *teamItem = [[UIBarButtonItem alloc] initWithCustomView:teamBtn];
    self.navigationItem.rightBarButtonItem = teamItem;
}

- (void)onTap:(id)sender
{
    UIView *titleView = self.navigationItem.titleView;
    if ([titleView isKindOfClass:[SAMCNavigationDropDownMenu class]]) {
        [((SAMCNavigationDropDownMenu *)self.navigationItem.titleView) hideMenu];
    }
}

- (void)refresh
{
    [self prepareData];
    [self.tableView reloadData];
}

- (void)prepareData
{
    _contacts = [[SAMCGroupedContacts alloc] initWithTag:self.currentContactTag];
    
    NSString *contactCellUtilIcon   = @"icon";
    NSString *contactCellUtilVC     = @"vc";
    NSString *contactCellUtilBadge  = @"badge";
    NSString *contactCellUtilTitle  = @"title";
    NSString *contactCellUtilUid    = @"uid";
    NSString *contactCellUtilSelectorName = @"selName";
    //原始数据
    
    NSInteger systemCount = [[[NIMSDK sharedSDK] systemNotificationManager] allUnreadCount];
    NSMutableArray *utils =
    [@[
       @{
           contactCellUtilIcon:@"icon_notification_normal",
           contactCellUtilTitle:@"验证消息",
           contactCellUtilVC:@"NTESSystemNotificationViewController",
           contactCellUtilBadge:@(systemCount)
           },
       @{
           contactCellUtilIcon:@"icon_team_advance_normal",
           contactCellUtilTitle:@"高级群",
           contactCellUtilVC:@"NTESAdvancedTeamListViewController"
           },
       @{
           contactCellUtilIcon:@"icon_team_normal_normal",
           contactCellUtilTitle:@"讨论组",
           contactCellUtilVC:@"NTESNormalTeamListViewController"
           },
       @{
           contactCellUtilIcon:@"icon_blacklist_normal",
           contactCellUtilTitle:@"黑名单",
           contactCellUtilVC:@"NTESBlackListViewController"
           },
       @{
           contactCellUtilIcon:@"icon_computer_normal",
           contactCellUtilTitle:@"我的电脑",
           contactCellUtilSelectorName:@"onEnterMyComputer"
           },
       ] mutableCopy];
    
    [self setUpNavItem];
    
    //构造显示的数据模型
    NTESContactUtilItem *contactUtil = [[NTESContactUtilItem alloc] init];
    NSMutableArray * members = [[NSMutableArray alloc] init];
    for (NSDictionary *item in utils) {
        NTESContactUtilMember *utilItem = [[NTESContactUtilMember alloc] init];
        utilItem.nick              = item[contactCellUtilTitle];
        utilItem.icon              = [UIImage imageNamed:item[contactCellUtilIcon]];
        utilItem.vcName            = item[contactCellUtilVC];
        utilItem.badge             = [item[contactCellUtilBadge] stringValue];
        utilItem.userId            = item[contactCellUtilUid];
        utilItem.selName           = item[contactCellUtilSelectorName];
        [members addObject:utilItem];
    }
    contactUtil.members = members;
    
    [_contacts addGroupAboveWithTitle:@"" members:contactUtil.members];
}


#pragma mark - Action
- (void)onEnterMyComputer{
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMSession *session = [NIMSession session:uid type:NIMSessionTypeP2P];
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onOpera:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择操作" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加好友",@"创建高级群",@"创建讨论组",@"搜索高级群", nil];
    __weak typeof(self) wself = self;
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        UIViewController *vc;
        switch (index) {
            case 0:
                vc = [[NTESContactAddFriendViewController alloc] initWithNibName:nil bundle:nil];
                break;
            case 1:{  //创建高级群
                [wself presentMemberSelector:^(NSArray *uids) {
                    NSArray *members = [@[currentUserId] arrayByAddingObjectsFromArray:uids];
                    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
                    option.name       = @"高级群";
                    option.type       = NIMTeamTypeAdvanced;
                    option.joinMode   = NIMTeamJoinModeNoAuth;
                    option.postscript = @"邀请你加入群组";
                    [SVProgressHUD show];
                    [[NIMSDK sharedSDK].teamManager createTeam:option users:members completion:^(NSError *error, NSString *teamId) {
                        [SVProgressHUD dismiss];
                        if (!error) {
                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                            NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
                            [wself.navigationController pushViewController:vc animated:YES];
                        }else{
                            [wself.view makeToast:@"创建失败" duration:2.0 position:CSToastPositionCenter];
                        }
                    }];
                }];
                break;
            }
            case 2:{ //创建讨论组
                [wself presentMemberSelector:^(NSArray *uids) {
                    if (!uids.count) {
                        return; //讨论组必须除自己外必须要有一个群成员
                    }
                    NSArray *members = [@[currentUserId] arrayByAddingObjectsFromArray:uids];
                    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
                    option.name       = @"讨论组";
                    option.type       = NIMTeamTypeNormal;
                    [SVProgressHUD show];
                    [[NIMSDK sharedSDK].teamManager createTeam:option users:members completion:^(NSError *error, NSString *teamId) {
                        [SVProgressHUD dismiss];
                        if (!error) {
                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                            NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
                            [wself.navigationController pushViewController:vc animated:YES];
                        }else{
                            [wself.view makeToast:@"创建失败" duration:2.0 position:CSToastPositionCenter];
                        }
                    }];
                }];
                break;
            }
            case 3:
                vc = [[NTESSearchTeamViewController alloc] initWithNibName:nil bundle:nil];
                break;
            default:
                break;
        }
        if (vc) {
            [wself.navigationController pushViewController:vc animated:YES];
        }
    }];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    if ([contactItem respondsToSelector:@selector(selName)] && [contactItem selName].length) {
        SEL sel = NSSelectorFromString([contactItem selName]);
        SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:nil]);
    }
    else if (contactItem.vcName.length) {
        Class clazz = NSClassFromString(contactItem.vcName);
        UIViewController * vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([contactItem respondsToSelector:@selector(userId)]){
        NSString * friendId   = contactItem.userId;
        [self enterPersonalCard:friendId];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return contactItem.uiHeight;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_contacts memberCountOfGroup:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_contacts groupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id contactItem = [_contacts memberOfIndex:indexPath];
    NSString * cellId = [contactItem reuseId];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        Class cellClazz = NSClassFromString([contactItem cellName]);
        cell = [[cellClazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([contactItem showAccessoryView]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([cell isKindOfClass:[NTESContactUtilCell class]]) {
        [(NTESContactUtilCell *)cell refreshWithContactItem:contactItem];
        [(NTESContactUtilCell *)cell setDelegate:self];
    }else{
        [(NIMContactDataCell *)cell refreshUser:contactItem];
        [(NIMContactDataCell *)cell setDelegate:self];
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_contacts titleOfGroup:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _contacts.sortedGroupTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index + 1;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    if ([contactItem userId].length) {
        return @[[self deleteAction], [self copyAction], [self chatAction]];
    } else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return [contactItem userId].length;
}

#pragma mark - NIMContactDataCellDelegate
- (void)onPressAvatar:(NSString *)memberId{
    [self enterPersonalCard:memberId];
}

#pragma mark - NTESContactUtilCellDelegate
- (void)onPressUtilImage:(NSString *)content{
    [self.view makeToast:[NSString stringWithFormat:@"点我干嘛 我是<%@>",content] duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - NIMContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts{
    
}

#pragma mark - NIMSDK Delegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    [self refresh];
}

- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        if (self.isViewLoaded) {//没有加载view的话viewDidLoad里会走一遍prepareData
            [self refresh];
        }
    }
}

#pragma mark - Notification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notfication
{
    [self refresh];
}

#pragma mark - Private
- (void)enterPersonalCard:(NSString *)userId{
    NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)presentMemberSelector:(ContactSelectFinishBlock) block{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    //使用内置的好友选择器
    NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
    //获取自己id
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    [users addObject:currentUserId];
    //将自己的id过滤
    config.filterIds = users;
    //需要多选
    config.needMutiSelected = YES;
    //初始化联系人选择器
    NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
    //回调处理
    vc.finshBlock = block;
    [vc show];
}

#pragma mark - UITableViewRowAction
- (UITableViewRowAction *)chatAction
{
    __weak typeof(self) wself = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Chat" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        id<NTESContactItem,NTESGroupMemberProtocol> contactItem = (id<NTESContactItem,NTESGroupMemberProtocol>)[wself.contacts memberOfIndex:indexPath];
        NSString *userId = [contactItem userId];
        [wself.tableView setEditing:NO animated:NO];
        NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
    action.backgroundColor = SAMC_COLOR_LIMEGREY;
    return action;
}

- (UITableViewRowAction *)copyAction
{
    __weak typeof(self) wself = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Copy" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        id<NTESContactItem,NTESGroupMemberProtocol> contactItem = (id<NTESContactItem,NTESGroupMemberProtocol>)[wself.contacts memberOfIndex:indexPath];
        NSString *userId = [contactItem userId];
        [wself.tableView setEditing:NO animated:YES];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __weak typeof(self) wself = self;
        for (NSString *tag in wself.contactTags) {
            if ([tag isEqualToString:SAMC_CONTACT_TAG_ALL] || [tag isEqualToString:wself.currentContactTag]) {
                continue;
            }
            NSString *actionTitle = [NSString stringWithFormat:@"Copy to %@", tag];
            [alertController addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [wself copyContact:userId toTag:tag];
            }]];
        }
        
        [alertController addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];
        [self presentViewController: alertController animated: YES completion: nil];
        
    }];
    action.backgroundColor = SAMC_COLOR_GREY;
    return action;
}

- (UITableViewRowAction *)deleteAction
{
    __weak typeof(self) wself = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        id<NTESContactItem,NTESGroupMemberProtocol> contactItem = (id<NTESContactItem,NTESGroupMemberProtocol>)[wself.contacts memberOfIndex:indexPath];
        NSString *userId = [contactItem userId];
        [SVProgressHUD showWithStatus:@"Deleting" maskType:SVProgressHUDMaskTypeBlack];
        [[SAMCUserManager sharedManager] addOrRemove:NO contact:userId tag:wself.currentContactTag completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
            } else {
                [wself.contacts removeGroupMember:contactItem];
                [wself refresh];
                [wself.view makeToast:@"delete success" duration:2 position:CSToastPositionCenter];
            }
        }];
    }];
    action.backgroundColor = SAMC_COLOR_RED;
    return action;
}

#pragma mark - Private
- (void)copyContact:(NSString *)userId toTag:(NSString *)tag
{
    [SVProgressHUD showWithStatus:@"Copying" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCUserManager sharedManager] addOrRemove:YES contact:userId tag:tag completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
        } else {
            [wself.view makeToast:@"copy success" duration:2 position:CSToastPositionCenter];
        }
    }];
}

@end
