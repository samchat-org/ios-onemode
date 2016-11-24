//
//  SAMCPreferenceManager.m
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPreferenceManager.h"
#import "SAMCDeviceUtil.h"

#define SAMCLoginDataAccount      @"account"
#define SAMCLoginDataToken        @"token"
@implementation SAMCLoginData

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _account = [aDecoder decodeObjectForKey:SAMCLoginDataAccount];
        _token = [aDecoder decodeObjectForKey:SAMCLoginDataToken];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([_account length]) {
        [encoder encodeObject:_account forKey:SAMCLoginDataAccount];
    }
    if ([_token length]) {
        [encoder encodeObject:_token forKey:SAMCLoginDataToken];
    }
}

- (NSString *)finalToken
{
    return [_token stringByAppendingString:[SAMCDeviceUtil deviceId]];
}

@end


#define SAMCPreLoginCountryCode @"countryCode"
#define SAMCPreLoginCellPhone   @"cellPhone"
#define SAMCPreLoginAvatarUrl   @"avatar"
@implementation SAMCPreLoginInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _countryCode = [aDecoder decodeObjectForKey:SAMCPreLoginCountryCode];
        _cellPhone = [aDecoder decodeObjectForKey:SAMCPreLoginCellPhone];
        _avatarUrl = [aDecoder decodeObjectForKey:SAMCPreLoginAvatarUrl];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([_countryCode length]) {
        [encoder encodeObject:_countryCode forKey:SAMCPreLoginCountryCode];
    }
    if ([_cellPhone length]) {
        [encoder encodeObject:_cellPhone forKey:SAMCPreLoginCellPhone];
    }
    if ([_avatarUrl length]) {
        [encoder encodeObject:_avatarUrl forKey:SAMCPreLoginAvatarUrl];
    }
}

@end

#define SAMC_CURRENTUSERMODE_KEY            @"samc_currentusermode_key"
#define SAMC_LOGINDATA_KEY                  @"samc_logindata_key"
#define SAMC_GETUIBINDEDALIAS_KEY           @"samc_getuibindedalias_key"
#define SAMC_NEEDQUESTIONNOTIFY_KEY         @"samc_needquestionnotify_key"
#define SAMC_NEEDSOUND_KEY                  @"samc_needsound_key"
#define SAMC_NEEDVIBRATE_KEY                @"samc_needvibrate_key"
#define SAMC_ADVRECALL_MINUTE_KEY           @"samc_advrecall_minute_key"
#define SAMC_PRELOGININFO_KEY               @"samc_prelogininfo_key"

@interface SAMCPreferenceManager ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SAMCPreferenceManager

@synthesize currentUserMode = _currentUserMode;
@synthesize loginData = _loginData;
@synthesize needQuestionNotify = _needQuestionNotify;
@synthesize needSound = _needSound;
@synthesize needVibrate = _needVibrate;
@synthesize advRecallTimeMinute = _advRecallTimeMinute;
@synthesize preLoginInfo = _preLoginInfo;

+ (instancetype)sharedManager
{
    static SAMCPreferenceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCPreferenceManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _syncQueue = dispatch_queue_create("com.github.gknows.samchat.preferenceQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)reset
{
    dispatch_barrier_async(_syncQueue, ^{
        _currentUserMode = @(SAMCUserModeTypeCustom);
        [[NSUserDefaults standardUserDefaults] setValue:_currentUserMode forKey:SAMC_CURRENTUSERMODE_KEY];
        _loginData = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAMC_LOGINDATA_KEY];
        _needQuestionNotify = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needQuestionNotify forKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
        _needSound = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needSound forKey:SAMC_NEEDSOUND_KEY];
        _needVibrate = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needVibrate forKey:SAMC_NEEDVIBRATE_KEY];
        _advRecallTimeMinute = @(2); // default to 2 minutes
        [[NSUserDefaults standardUserDefaults] setValue:_advRecallTimeMinute forKey:SAMC_ADVRECALL_MINUTE_KEY];
        // do not reset preLoginInfo
    });
}

#pragma mark - currentUserMode
- (NSNumber *)currentUserMode
{
    __block NSNumber *mode;
    dispatch_sync(_syncQueue, ^{
        if (_currentUserMode == nil) {
            _currentUserMode = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_CURRENTUSERMODE_KEY];
            _currentUserMode = _currentUserMode ?: @(SAMCUserModeTypeCustom);
        }
        mode = _currentUserMode;
    });
    return mode;
}

- (void)setCurrentUserMode:(NSNumber *)currentUserMode
{
    dispatch_barrier_async(_syncQueue, ^{
        _currentUserMode = currentUserMode;
        [[NSUserDefaults standardUserDefaults] setValue:currentUserMode forKey:SAMC_CURRENTUSERMODE_KEY];
    });
}

#pragma mark - loginData
- (SAMCLoginData *)loginData
{
    __block SAMCLoginData *loginData;
    dispatch_sync(_syncQueue, ^{
        if (_loginData == nil) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SAMC_LOGINDATA_KEY];
            if (data) {
                _loginData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        loginData = _loginData;
    });
    return loginData;
}

- (void)setLoginData:(SAMCLoginData *)loginData
{
    dispatch_barrier_async(_syncQueue, ^{
        _loginData = loginData;
        if (loginData) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loginData];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:SAMC_LOGINDATA_KEY];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAMC_LOGINDATA_KEY];
        }
    });
}

#pragma mark - needQuestionNotify
- (NSNumber *)needQuestionNotify
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_needQuestionNotify == nil) {
            _needQuestionNotify = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
            _needQuestionNotify = _needQuestionNotify ?:@(YES);
        }
        flag = _needQuestionNotify;
    });
    return flag;
}

- (void)setNeedQuestionNotify:(NSNumber *)needQuestionNotify
{
    dispatch_barrier_async(_syncQueue, ^{
        _needQuestionNotify = needQuestionNotify;
        [[NSUserDefaults standardUserDefaults] setValue:needQuestionNotify forKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
    });
}

#pragma mark - needSound
- (NSNumber *)needSound
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_needSound == nil) {
            _needSound = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_NEEDSOUND_KEY];
            _needSound = _needSound ?:@(YES);
        }
        flag = _needSound;
    });
    return flag;
}

- (void)setNeedSound:(NSNumber *)needSound
{
    dispatch_barrier_async(_syncQueue, ^{
        _needSound = needSound;
        [[NSUserDefaults standardUserDefaults] setValue:needSound forKey:SAMC_NEEDSOUND_KEY];
    });
}

#pragma mark - needVibrate
- (NSNumber *)needVibrate
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_needVibrate == nil) {
            _needVibrate = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_NEEDVIBRATE_KEY];
            _needVibrate = _needVibrate ?:@(YES);
        }
        flag = _needVibrate;
    });
    return flag;
}

- (void)setNeedVibrate:(NSNumber *)needVibrate
{
    dispatch_barrier_async(_syncQueue, ^{
        _needVibrate = needVibrate;
        [[NSUserDefaults standardUserDefaults] setValue:needVibrate forKey:SAMC_NEEDVIBRATE_KEY];
    });
}

#pragma mark - advRecallTimeMinute
- (NSNumber *)advRecallTimeMinute
{
    __block NSNumber *minutes;
    dispatch_sync(_syncQueue, ^{
        if (_advRecallTimeMinute == nil) {
            _advRecallTimeMinute = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_ADVRECALL_MINUTE_KEY];
            _advRecallTimeMinute = _advRecallTimeMinute ?:@(2);
        }
        minutes = _advRecallTimeMinute;
    });
    return minutes;
}

- (void)setAdvRecallTimeMinute:(NSNumber *)advRecallTimeMinute
{
    dispatch_barrier_async(_syncQueue, ^{
        _advRecallTimeMinute = advRecallTimeMinute;
        [[NSUserDefaults standardUserDefaults] setValue:advRecallTimeMinute forKey:SAMC_ADVRECALL_MINUTE_KEY];
    });
}

#pragma mark - preLoginInfo
- (SAMCPreLoginInfo *)preLoginInfo
{
    __block SAMCPreLoginInfo *info;
    dispatch_sync(_syncQueue, ^{
        if (_preLoginInfo == nil) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SAMC_PRELOGININFO_KEY];
            if (data) {
                _preLoginInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        info = _preLoginInfo;
    });
    return info;
}

- (void)setPreLoginInfo:(SAMCPreLoginInfo *)preLoginInfo
{
    dispatch_barrier_async(_syncQueue, ^{
        _preLoginInfo = preLoginInfo;
        if (preLoginInfo) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:preLoginInfo];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:SAMC_PRELOGININFO_KEY];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAMC_PRELOGININFO_KEY];
        }
    });
}

@end
