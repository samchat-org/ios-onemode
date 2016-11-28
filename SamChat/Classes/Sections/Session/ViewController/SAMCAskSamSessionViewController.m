//
//  SAMCAskSamSessionViewController.m
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAskSamSessionViewController.h"
@import MobileCoreServices;
@import AVFoundation;
#import "UIActionSheet+NTESBlock.h"
#import "NTESSessionMsgConverter.h"
#import "NTESFileLocationHelper.h"
#import "NTESSessionMsgConverter.h"
#import "UIView+Toast.h"
#import "NTESGalleryViewController.h"
#import "NTESLocationViewController.h"
#import "NTESVideoViewController.h"
#import "NTESLocationPoint.h"
#import "NTESFilePreViewController.h"
#import "NTESAudio2TextViewController.h"
#import "NSDictionary+NTESJson.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESPersonalCardViewController.h"
#import "NIMContactSelectViewController.h"
#import "SVProgressHUD.h"
#import "NTESSessionCardViewController.h"
#import "NTESFPSLabel.h"
#import "UIAlertView+NTESBlock.h"
#import "NTESSessionUtil.h"
#import "SAMCAskSamSessionConfig.h"

@interface SAMCAskSamSessionViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) SAMCAskSamSessionConfig *sessionConfig;
@property (nonatomic, strong) UIView *currentSingleSnapView;
@property (nonatomic, strong) NTESFPSLabel *fpsLabel;

@end

@implementation SAMCAskSamSessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    DDLogInfo(@"enter session, id = %@",self.session.sessionId);
    if ([[NTESBundleSetting sharedConfig] showFps]) {
        self.fpsLabel = [[NTESFPSLabel alloc] initWithFrame:CGRectZero];
        [self.view addSubview:self.fpsLabel];
        self.fpsLabel.right = self.view.width;
        self.fpsLabel.top   = self.tableView.top + self.tableView.contentInset.top;
    }
}

- (void)dealloc
{
    [_fpsLabel invalidate];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.fpsLabel.right = self.view.width;
    self.fpsLabel.top   = self.tableView.top + self.tableView.contentInset.top;
}

- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[SAMCAskSamSessionConfig alloc] init];
    }
    return _sessionConfig;
}

#pragma mark - Cell事件
- (void)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = NO;
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink])
    {
        NSString *link = event.data;
        [self.view makeToast:[NSString stringWithFormat:@"tap link : %@",link]
                    duration:2
                    position:CSToastPositionCenter];
        handled = YES;
    }
    
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
}

- (void)onLongPressCell:(NIMMessage *)message inView:(UIView *)view
{
    [super onLongPressCell:message
                    inView:view];
}

- (void)onTapAvatar:(NSString *)userId{
    UIViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Cell Actions
- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

- (void)showVideo:(NIMMessage *)message
{
    NIMVideoObject *object = message.messageObject;
    NTESVideoViewController *playerViewController = [[NTESVideoViewController alloc] initWithVideoObject:object];
    [self.navigationController pushViewController:playerViewController animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]){
        //如果封面图下跪了，点进视频的时候再去下一把封面图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.coverUrl filepath:object.coverPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

- (void)showLocation:(NIMMessage *)message
{
    NIMLocationObject *object = message.messageObject;
    NTESLocationPoint *locationPoint = [[NTESLocationPoint alloc] initWithLocationObject:object];
    NTESLocationViewController *vc = [[NTESLocationViewController alloc] initWithLocationPoint:locationPoint];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFile:(NIMMessage *)message
{
    NIMFileObject *object = message.messageObject;
    NTESFilePreViewController *vc = [[NTESFilePreViewController alloc] initWithFileObject:object];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCustom:(NIMMessage *)message
{
    //普通的自定义消息点击事件可以在这里做哦~
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    if (defaultItems) {
        [items addObjectsFromArray:defaultItems];
    }
    
    if ([NTESSessionUtil canMessageBeForwarded:message]) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage:)]];
    }
    
    if ([NTESSessionUtil canMessageBeRevoked:message]) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeMessage:)]];
    }
    
    if (message.messageType == NIMMessageTypeAudio) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转文字" action:@selector(audio2Text:)]];
    }
    
    return items;
    
}

- (void)audio2Text:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) wself = self;
    NTESAudio2TextViewController *vc = [[NTESAudio2TextViewController alloc] initWithMessage:message];
    vc.completeHandler = ^(void){
        [wself uiUpdateMessage:message];
    };
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
}


- (void)forwardMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择会话类型" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"个人",@"群组", nil];
    __weak typeof(self) weakSelf = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
                config.needMutiSelected = NO;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *userId = array.firstObject;
                    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 1:{
                NIMContactTeamSelectConfig *config = [[NIMContactTeamSelectConfig alloc] init];
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *teamId = array.firstObject;
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 2:
                break;
            default:
                break;
        }
    }];
}


- (void)revokeMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatManager revokeMessage:message completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送时间超过2分钟的消息，不能被撤回" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                DDLogError(@"revoke message eror code %zd",error.code);
                [weakSelf.view makeToast:@"消息撤回失败，请重试" duration:2.0 position:CSToastPositionCenter];
            }
        }
        else
        {
            NIMMessageModel *model = [self uiDeleteMessage:message];
            NIMMessage *tip = [NTESSessionMsgConverter msgWithTip:[NTESSessionUtil tipOnMessageRevoked:message]];
            tip.timestamp = model.messageTime;
            [self uiAddMessages:@[tip]];
            
            tip.timestamp = message.timestamp;
            // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
            [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:message.session completion:nil];
        }
    }];
}


- (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
    NSString *name;
    if (session.sessionType == NIMSessionTypeP2P) {
        name = [[NIMKit sharedKit] infoByUser:session.sessionId inSession:session].showName;
    }
    else {
        name = [[NIMKit sharedKit] infoByTeam:session.sessionId].showName;
    }
    NSString *tip = [NSString stringWithFormat:@"确认转发给 %@ ?",name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认转发" message:tip delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    __weak typeof(self) weakSelf = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if(index == 1){
            [[NIMSDK sharedSDK].chatManager forwardMessage:message toSession:session error:nil];
            [weakSelf.view makeToast:@"已发送" duration:2.0 position:CSToastPositionCenter];
        }
    }];
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeAudio) :    @"playAudio:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeLocation) : @"showLocation:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

@end
