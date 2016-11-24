//
//  SAMCSMSLoginViewController.m
//  SamChat
//
//  Created by HJ on 11/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSMSLoginViewController.h"
#import "SAMCPhoneCodeView.h"
#import "SVProgressHUD.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"

@interface SAMCSMSLoginViewController ()<SAMCPhoneCodeViewDelegate>

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *cellPhone;

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCPhoneCodeView *phoneCodeView;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation SAMCSMSLoginViewController

- (instancetype)initWithCountryCode:(NSString *)countryCode cellPhone:(NSString *)cellPhone
{
    self = [super init];
    if (self) {
        _countryCode = countryCode;
        _cellPhone = cellPhone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.phoneCodeView becomeFirstResponder];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Login";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.phoneCodeView];
    [self.view addSubview:self.loginButton];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(22);
    }];
    
    [self.phoneCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(25);
        make.height.equalTo(@44);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.phoneCodeView.mas_bottom).with.offset(20);
    }];
}

#pragma mark - SAMCPhoneCodeViewDelegate
- (void)phonecodeDidChange:(SAMCPhoneCodeView *)view
{
    self.loginButton.enabled = (view.phoneCode.length == 4);
}

#pragma mark - Action
- (void)login:(id)sender
{
    NSString *verifyCode = self.phoneCodeView.phoneCode;
    [SVProgressHUD showWithStatus:@"Login" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCAccountManager sharedManager] loginWithCountryCode:_countryCode cellPhone:_cellPhone verifyCode:verifyCode completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
            return;
        }
        extern NSString *SAMCLoginNotification;
        [[NSNotificationCenter defaultCenter] postNotificationName:SAMCLoginNotification object:nil userInfo:nil];
    }];
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = SAMC_COLOR_INK;
        _tipLabel.text = @"Enter the confirmation code";
    }
    return _tipLabel;
}

- (SAMCPhoneCodeView *)phoneCodeView
{
    if (_phoneCodeView == nil) {
        _phoneCodeView = [[SAMCPhoneCodeView alloc] initWithFrame:CGRectZero];
        _phoneCodeView.delegate = self;
    }
    return _phoneCodeView;
}

- (UIButton *)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _loginButton.exclusiveTouch = YES;
        _loginButton.layer.cornerRadius = 20.0f;
        _loginButton.layer.masksToBounds = YES;
        _loginButton.enabled = NO;
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitleColor:SAMC_COLOR_WHITE_HINT forState:UIControlStateHighlighted];
        [_loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

@end
