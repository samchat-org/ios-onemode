//
//  SAMCMainTabController.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMainTabController.h"
#import "SAMCAppDelegate.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"
#import "NTESNavigationHandler.h"
#import "SAMCAccountManager.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabbarItemBadgeValue @"badgeValue"
#define TabBarCount 5

typedef NS_ENUM(NSInteger,SAMCMainTabType) {
    SAMCMainTabTypeMessageList,
    SAMCMainTabTypeContact,
    SAMCMainTabTypePublic,
    SAMCMainTabTypeForum,
    SAMCMainTabTypeSetting,
};

@interface SAMCMainTabController ()<NIMSystemNotificationManagerDelegate,NIMConversationManagerDelegate>

@property (nonatomic,strong) NSArray *navigationHandlers;

@property (nonatomic,assign) NSInteger sessionUnreadCount;

@property (nonatomic,assign) NSInteger systemUnreadCount;

@property (nonatomic,assign) NSInteger customSystemUnreadCount;

@property (nonatomic,copy)  NSDictionary *configs;

@end

@implementation SAMCMainTabController

+ (instancetype)instance
{
    SAMCAppDelegate *delegete = (SAMCAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = delegete.window.rootViewController;
    if ([vc isKindOfClass:[SAMCMainTabController class]]) {
        return (SAMCMainTabController *)vc;
    }else{
        return nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpSubNav];
    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotifyChanged:)
                                                 name:NTESCustomNotificationCountChanged
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpStatusBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //会话界面发送拍摄的视频，拍摄结束后点击发送后可能顶部会有红条，导致的界面错位。
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)tabbars
{
    self.sessionUnreadCount  = [NIMSDK sharedSDK].conversationManager.allUnreadCount;
    self.systemUnreadCount   = [NIMSDK sharedSDK].systemNotificationManager.allUnreadCount;
    self.customSystemUnreadCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSInteger tabbar = 0; tabbar < TabBarCount; tabbar++) {
        [items addObject:@(tabbar)];
    }
    return items;
}

- (void)setUpSubNav
{
    NSMutableArray *handleArray = [[NSMutableArray alloc] init];
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item =[self vcInfoForTabType:[obj integerValue]];
        NSString *vcName = item[TabbarVC];
        NSString *title  = item[TabbarTitle];
        NSString *imageName = item[TabbarImage];
        NSString *imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        vc.hidesBottomBarWhenPushed = NO;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.translucent = NO;
        UIImage *normalImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *pressedImage = [[UIImage imageNamed:imageSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                       image:normalImage
                                               selectedImage:pressedImage];
        [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SAMC_COLOR_INGRABLUE} forState:UIControlStateNormal];
        
        nav.tabBarItem.tag = idx;
        NSInteger badge = [item[TabbarItemBadgeValue] integerValue];
        if (badge) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",badge];
        }
        NTESNavigationHandler *handler = [[NTESNavigationHandler alloc] initWithNavigationController:nav];
        nav.delegate = handler;
        
        [vcArray addObject:nav];
        [handleArray addObject:handler];
    }];
    self.viewControllers = [NSArray arrayWithArray:vcArray];
    self.navigationHandlers = [NSArray arrayWithArray:handleArray];
}

- (void)setUpStatusBar
{
    UIStatusBarStyle style;
    if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
        style = UIStatusBarStyleLightContent;
    } else {
        style = UIStatusBarStyleDefault;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount
{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}

- (void)messagesDeletedInSession:(NIMSession *)session
{
    self.sessionUnreadCount = [NIMSDK sharedSDK].conversationManager.allUnreadCount;
    [self refreshSessionBadge];
}

- (void)allMessagesDeleted
{
    self.sessionUnreadCount = 0;
    [self refreshSessionBadge];
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    self.systemUnreadCount = unreadCount;
    [self refreshContactBadge];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    NTESCustomNotificationDB *db = [NTESCustomNotificationDB sharedInstance];
    self.customSystemUnreadCount = db.unreadCount;
    [self refreshSettingBadge];
}

- (void)refreshSessionBadge
{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeMessageList];
    nav.tabBarItem.badgeValue = self.sessionUnreadCount ? @(self.sessionUnreadCount).stringValue : nil;
}

- (void)refreshContactBadge
{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeContact];
    NSInteger badge = self.systemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}

- (void)refreshSettingBadge
{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeSetting];
    NSInteger badge = self.customSystemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - NTESNavigationGestureHandlerDataSource
- (UINavigationController *)navigationController
{
    return self.selectedViewController;
}

#pragma mark - VC
- (NSDictionary *)vcInfoForTabType:(SAMCMainTabType)type
{
    
    if (_configs == nil)
    {
        _configs = @{
                     @(SAMCMainTabTypeMessageList) : @{
                             TabbarVC           : @"SAMCSessionListViewController",
                             TabbarTitle        : @"Chat",
                             TabbarImage        : @"ico_tab_chat_line",
                             TabbarSelectedImage: @"ico_tab_chat_fill",
                             TabbarItemBadgeValue: @(self.sessionUnreadCount)
                             },
                     @(SAMCMainTabTypeContact)     : @{
                             TabbarVC           : @"NTESContactViewController",
                             TabbarTitle        : @"Contact",
                             TabbarImage        : @"ico_tab_contacts_line",
                             TabbarSelectedImage: @"ico_tab_contacts_fill",
                             TabbarItemBadgeValue: @(self.systemUnreadCount)
                             },
                     @(SAMCMainTabTypePublic): @{
                             TabbarVC           : @"SAMCPublicViewController",
                             TabbarTitle        : @"Public",
                             TabbarImage        : @"ico_tab_public_line",
                             TabbarSelectedImage: @"ico_tab_public_fill",
                             },
                     @(SAMCMainTabTypeForum): @{
                             TabbarVC           : @"SAMCForumViewController",
                             TabbarTitle        : @"Forum",
                             TabbarImage        : @"ico_tab_forum_line",
                             TabbarSelectedImage: @"ico_tab_forum_fill",
                             },
                     @(SAMCMainTabTypeSetting)     : @{
                             TabbarVC           : @"SAMCMeViewController",
                             TabbarTitle        : @"Me",
                             TabbarImage        : @"ico_tab_account_customer_line",
                             TabbarSelectedImage: @"ico_tab_account_customer_fill",
                             TabbarItemBadgeValue: @(self.customSystemUnreadCount)
                             }
                     };
        
    }
    return _configs[@(type)];
}

@end