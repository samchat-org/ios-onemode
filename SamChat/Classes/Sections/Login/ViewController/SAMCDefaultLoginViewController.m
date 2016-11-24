//
//  SAMCDefaultLoginViewController.m
//  SamChat
//
//  Created by HJ on 11/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDefaultLoginViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCPadImageView.h"
#import "SAMCMobileLoginViewController.h"
#import "SAMCAccountLoginViewController.h"
#import "SVProgressHUD.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"

@interface SAMCDefaultLoginViewController ()

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *avatarUrl;

@property (nonatomic, strong) SAMCCardPortraitView *portraitView;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgetPWDButton;
@property (nonatomic, strong) UIButton *viaSMSButton;
@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation SAMCDefaultLoginViewController

- (instancetype)initWithCountryCode:(NSString *)countryCode
                          cellPhone:(NSString *)cellPhone
                          avatarUrl:(NSString *)avatarUrl
{
    self = [super init];
    if (self) {
        _countryCode = countryCode;
        _phoneNumber = cellPhone;
        _avatarUrl = avatarUrl;
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Login";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self.view addSubview:self.portraitView];
    [self.view addSubview:self.phoneLabel];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.forgetPWDButton];
    [self.view addSubview:self.viaSMSButton];
    [self.view addSubview:self.moreButton];
    
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@140);
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.portraitView.mas_bottom).with.offset(0);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.top.equalTo(self.phoneLabel.mas_bottom).with.offset(20);
        make.height.equalTo(@40);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.passwordTextField.mas_bottom).with.offset(20);
    }];
    
    [self.forgetPWDButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginButton);
        make.top.equalTo(self.loginButton.mas_bottom).with.offset(20);
    }];
    
    [self.viaSMSButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.loginButton);
        make.top.equalTo(self.loginButton.mas_bottom).with.offset(20);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-20);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Action
- (void)touchDone:(id)sender
{
    if (self.loginButton.enabled) {
        [self login:nil];
    }
}

- (void)login:(id)sender
{
    [SVProgressHUD showWithStatus:@"login" maskType:SVProgressHUDMaskTypeBlack];
    [_passwordTextField resignFirstResponder];
    
    NSString *password = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __weak typeof(self) wself = self;
    [[SAMCAccountManager sharedManager] loginWithCountryCode:_countryCode cellPhone:_phoneNumber password:password completion:^(NSError * _Nullable error) {
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

- (void)forgotPassword:(id)sender
{
}

- (void)loginViaSMS:(id)sender
{
}

- (void)more:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) wself = self;
    UIAlertAction *phoneAction = [UIAlertAction actionWithTitle:@"Phone" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SAMCMobileLoginViewController *vc = [[SAMCMobileLoginViewController alloc] init];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *samchatIdAction = [UIAlertAction actionWithTitle:@"SamChat ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SAMCAccountLoginViewController *vc = [[SAMCAccountLoginViewController alloc] init];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:phoneAction];
    [alertController addAction:samchatIdAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - textField
- (void)textFieldEditingChanged:(UITextField *)textField
{
}

#pragma mark - lazy load
- (SAMCCardPortraitView *)portraitView
{
    if (_portraitView == nil) {
        _portraitView = [[SAMCCardPortraitView alloc] initWithFrame:CGRectZero effect:NO];
        _portraitView.avatarUrl = _avatarUrl;
    }
    return _portraitView;
}

- (UILabel *)phoneLabel
{
    if (_phoneLabel == nil) {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.font = [UIFont boldSystemFontOfSize:21.0f];
        _phoneLabel.textColor = SAMC_COLOR_INK;
        _phoneLabel.textAlignment = NSTextAlignmentCenter;
        _phoneLabel.text = [NSString stringWithFormat:@"+%@-%@",_countryCode,_phoneNumber];
    }
    return _phoneLabel;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTextField.layer.cornerRadius = 6.0f;
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.textColor = SAMC_COLOR_INK;
        _passwordTextField.font = [UIFont systemFontOfSize:17.0f];
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_INK_HINT,NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [_passwordTextField addTarget:self action:@selector(touchDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_passwordTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        
        _passwordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _passwordTextField;
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

- (UIButton *)forgetPWDButton
{
    if (_forgetPWDButton == nil) {
        _forgetPWDButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _forgetPWDButton.exclusiveTouch = YES;
        _forgetPWDButton.backgroundColor = [UIColor clearColor];
        [_forgetPWDButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
        [_forgetPWDButton setTitleColor:SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5) forState:UIControlStateHighlighted];
        _forgetPWDButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_forgetPWDButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
        _forgetPWDButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_forgetPWDButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPWDButton;
}

- (UIButton *)viaSMSButton
{
    if (_viaSMSButton == nil) {
        _viaSMSButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _viaSMSButton.exclusiveTouch = YES;
        _viaSMSButton.backgroundColor = [UIColor clearColor];
        [_viaSMSButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
        [_viaSMSButton setTitleColor:SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5) forState:UIControlStateHighlighted];
        _viaSMSButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_viaSMSButton setTitle:@"Log in via SMS" forState:UIControlStateNormal];
        _viaSMSButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_viaSMSButton addTarget:self action:@selector(loginViaSMS:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viaSMSButton;
}

- (UIButton *)moreButton
{
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _moreButton.exclusiveTouch = YES;
        _moreButton.backgroundColor = [UIColor clearColor];
        [_moreButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
        [_moreButton setTitleColor:SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5) forState:UIControlStateHighlighted];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_moreButton setTitle:@"More" forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

@end
