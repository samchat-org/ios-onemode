//
//  SAMCQuestionManager.m
//  SamChat
//
//  Created by HJ on 8/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQuestionManager.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "NTESSessionMsgConverter.h"
#import "GCDMulticastDelegate.h"

@interface SAMCQuestionManager ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCQuestionManagerDelegate> *questionDelegate;
@property (nonatomic, strong) NSMutableArray *sendingMessages;

@end

@implementation SAMCQuestionManager

+ (instancetype)sharedManager
{
    static SAMCQuestionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCQuestionManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _sendingMessages = [[NSMutableArray alloc] init];
        _questionDelegate = (GCDMulticastDelegate <SAMCQuestionManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return self;
}

- (void)addDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [self.questionDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [self.questionDelegate removeDelegate:delegate];
}

- (BOOL)isMessageSending:(NIMMessage *)message
{
    return [self.sendingMessages containsObject:message];
}

- (void)sendQuestion:(NSString *)question location:(NSDictionary *)location
{
    NIMSession *session = [NIMSession session:SAMC_SAMCHAT_ACCOUNT_ASKSAM type:NIMSessionTypeP2P];
    NIMMessage *message = [NTESSessionMsgConverter msgWithText:question];
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.shouldBeCounted = NO;
    message.setting = setting;
    message.localExt = @{MESSAGE_LOCAL_EXT_DELIVERYSTATE_KEY:@(NIMMessageDeliveryStateFailed)};
    
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:^(NSError * _Nullable error) {
        if (!error) {
            [wself.sendingMessages addObject:message];
            [wself sendQuestion:question location:location completion:^(NSError * _Nullable error, NSDictionary * __nullable response) {
                [wself.sendingMessages removeObject:message];
                NSMutableDictionary *localExt = [message.localExt mutableCopy];
                if (!error) {
                    [localExt setObject:@(NIMMessageDeliveryStateDeliveried) forKey:MESSAGE_LOCAL_EXT_DELIVERYSTATE_KEY];
                    if (response[SAMC_QUESTION_ID]) {
                        [localExt setObject:response[SAMC_QUESTION_ID] forKey:SAMC_QUESTION_ID];
                    }
                    if (response[SAMC_DATETIME]) {
                        [localExt setObject:response[SAMC_DATETIME] forKey:SAMC_DATETIME];
                    }
                } else {
                    [localExt setObject:@(NIMMessageDeliveryStateFailed) forKey:MESSAGE_LOCAL_EXT_DELIVERYSTATE_KEY];
                }
                message.localExt = localExt;
                [[NIMSDK sharedSDK].conversationManager updateMessage:message forSession:session completion:NULL];
                [wself.questionDelegate sendQuestionMessage:message didCompleteWithError:error];
            }];
        }
    }];
}

- (void)sendQuestion:(NSString *)question
            location:(NSDictionary *)location
          completion:(void (^)(NSError * __nullable error, NSDictionary * __nullable response))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI sendQuestion:question location:location];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_QUESTION_QUESTION parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode], nil);
            } else {
                completion(nil, parameters[SAMC_BODY]);
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable], nil);
    }];
}

@end
