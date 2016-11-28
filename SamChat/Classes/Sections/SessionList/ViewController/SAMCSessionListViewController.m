//
//  SAMCSessionListViewController.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSessionListViewController.h"
#import "NTESSessionViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESListHeader.h"
#import "NTESClientsTableViewController.h"
#import "NTESSessionUtil.h"
#import "NTESPersonalCardViewController.h"
#import "NIMMessage+SAMC.h"
#import "SAMCSessionListCell.h"
#import "UIView+NIM.h"
#import "NIMAvatarImageView.h"
#import "NIMKitUtil.h"
#import "SAMCConversationManager.h"
#import "SAMCAskSamSessionViewController.h"

#define SessionListTitle @"Chat"

@interface SAMCSessionListViewController ()<NIMLoginManagerDelegate,NTESListHeaderDelegate,NIMConversationManagerDelegate,NIMTeamManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) NTESListHeader *header;
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray * recentSessions;

@property (nonatomic,assign) BOOL autoRemoveRemoteSession;

@end

@implementation SAMCSessionListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.autoRemoveRemoteSession = [[NTESBundleSetting sharedConfig] autoRemoveRemoteSession];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = SessionListTitle;
    
    self.header = [[NTESListHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    [self.view addSubview:self.header];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.tableFooterView  = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _recentSessions = [[[SAMCConversationManager sharedManager] allChatSessions] mutableCopy];
    if (!self.recentSessions.count) {
        _recentSessions = [NSMutableArray array];
    }
    
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    extern NSString *const NIMKitTeamInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamInfoHasUpdatedNotification:) name:NIMKitTeamInfoHasUpdatedNotification object:nil];
    
    extern NSString *const NIMKitTeamMembersHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamMembersHasUpdatedNotification:) name:NIMKitTeamMembersHasUpdatedNotification object:nil];
    
    extern NSString *const NIMKitUserInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self refreshSubview];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NIMRecentSession *recentSession = self.recentSessions[indexPath.row];
    UIViewController *vc;
    if ([recentSession.session.sessionId isEqualToString:SAMC_SAMCHAT_ACCOUNT_ASKSAM]) {
        vc = [[SAMCAskSamSessionViewController alloc] initWithSession:recentSession.session];
    } else {
        vc = [[NTESSessionViewController alloc] initWithSession:recentSession.session];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMRecentSession *recentSession = self.recentSessions[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
        
        [manager deleteRecentSession:recentSession];
        
        //清理本地数据
        [self.recentSessions removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //如果删除本地会话后就不允许漫游当前会话，则需要进行一次删除服务器会话的操作
        if (self.autoRemoveRemoteSession)
        {
            [manager deleteRemoteSessions:@[recentSession.session]
                               completion:nil];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recentSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SAMCSessionListCellId";
    SAMCSessionListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCSessionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.recentSession = self.recentSessions[indexPath.row];
    return cell;
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self.recentSessions addObject:recentSession];
    [self sort];
    [self reload];
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    for (NIMRecentSession *recent in self.recentSessions) {
        if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId]) {
            [self.recentSessions removeObject:recent];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:recentSession];
    [self.recentSessions insertObject:recentSession atIndex:insert];
    [self reload];
}

- (void)messagesDeletedInSession:(NIMSession *)session
{
    _recentSessions = [[[SAMCConversationManager sharedManager] allChatSessions] mutableCopy];
    [self reload];
}

- (void)allMessagesDeleted
{
    _recentSessions = [[[SAMCConversationManager sharedManager] allChatSessions] mutableCopy];
    [self reload];
}

#pragma mark - Misc
- (NSInteger)findInsertPlace:(NIMRecentSession *)recentSession
{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.recentSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NIMRecentSession *item = obj;
        if ((![item.session.sessionId hasPrefix:SAMC_SAMCHAT_ACCOUNT_PREFIX]) &&
            (item.lastMessage.timestamp <= recentSession.lastMessage.timestamp)) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.recentSessions.count;
    }
}

- (void)sort
{
    [self.recentSessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NIMRecentSession *item1 = obj1;
        NIMRecentSession *item2 = obj2;
        if ([item1.session.sessionId hasPrefix:SAMC_SAMCHAT_ACCOUNT_PREFIX]) {
            return NSOrderedAscending;
        }
        if ([item2.session.sessionId hasPrefix:SAMC_SAMCHAT_ACCOUNT_PREFIX]) {
            return NSOrderedDescending;
        }
        if (item1.lastMessage.timestamp < item2.lastMessage.timestamp) {
            return NSOrderedDescending;
        }
        if (item1.lastMessage.timestamp > item2.lastMessage.timestamp) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)onTouchAvatar:(id)sender
{
    UIView *view = [sender superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    UITableViewCell *cell  = (UITableViewCell *)view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NIMRecentSession *recent = self.recentSessions[indexPath.row];
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:recent.session.sessionId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification{
    [self reload];
}

- (void)onTeamInfoHasUpdatedNotification:(NSNotification *)notification{
    [self reload];
}

- (void)onTeamMembersHasUpdatedNotification:(NSNotification *)notification{
    [self reload];
}

#pragma mark - SessionListHeaderDelegate
- (void)didSelectRowType:(NTESListHeaderType)type
{
    //多人登录
    switch (type) {
        case ListHeaderTypeLoginClients:{
            NTESClientsTableViewController *vc = [[NTESClientsTableViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        [self reload];
    }
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(Disconnected)"];
            break;
        case NIMLoginStepLinking:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(Connecting)"];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.titleLabel.text = SessionListTitle;
            break;
        case NIMLoginStepSyncing:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(Syncing)"];
            break;
        default:
            break;
    }
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    [self.header refreshWithType:ListHeaderTypeNetStauts value:@(step)];
    [self.view setNeedsLayout];
}

- (void)onMultiLoginClientsChanged
{
    [self.header refreshWithType:ListHeaderTypeLoginClients value:[NIMSDK sharedSDK].loginManager.currentLoginClients];
    [self.view setNeedsLayout];
}

#pragma mark - Private
- (void)refreshSubview
{
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    self.tableView.top = self.header.height;
    self.tableView.height = self.view.height - self.tableView.top;
    self.header.bottom = self.tableView.top + self.tableView.contentInset.top;
}

@end
