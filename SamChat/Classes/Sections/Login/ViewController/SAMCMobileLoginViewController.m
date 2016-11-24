//
//  SAMCMobileLoginViewController.m
//  SamChat
//
//  Created by HJ on 11/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMobileLoginViewController.h"
#import "SAMCCountryCodeViewController.h"
#import "SAMCAccountLoginViewController.h"
#import "SAMCConfirmPhoneNumViewController.h"
#import "NSString+SAMC.h"
#import "SAMCTextField.h"
#import "SAMCPadImageView.h"
#import "SVProgressHUD.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"

@interface SAMCMobileLoginViewController ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgetPWDButton;
@property (nonatomic, strong) UIButton *viaSMSButton;
@property (nonatomic, strong) UIButton *changeLoginModeButton;

@property (nonatomic, copy) NSString *countryCode;

@end

@implementation SAMCMobileLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Login";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.forgetPWDButton];
    [self.view addSubview:self.viaSMSButton];
    [self.view addSubview:self.changeLoginModeButton];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(22);
    }];
    
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(20);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.phoneTextField.mas_bottom).with.offset(20);
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
    
    [self.changeLoginModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
- (void)selectCountryCode:(UIButton *)sender
{
    SAMCCountryCodeViewController *countryCodeController = [[SAMCCountryCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    countryCodeController.selectBlock = ^(NSString *text){
        [weakSelf.phoneTextField.leftButton setTitle:text forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:countryCodeController animated:YES];
}

- (void)touchDone:(id)sender
{
    if (self.loginButton.enabled) {
        [self login:nil];
    }
}

- (void)login:(id)sender
{
    [SVProgressHUD showWithStatus:@"login" maskType:SVProgressHUDMaskTypeBlack];
    [_phoneTextField.rightTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    NSString *countryCode = _phoneTextField.leftButton.titleLabel.text;
    countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *cellPhone = [_phoneTextField.rightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __weak typeof(self) wself = self;
    [[SAMCAccountManager sharedManager] loginWithCountryCode:countryCode cellPhone:cellPhone password:password completion:^(NSError * _Nullable error) {
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
    SAMCConfirmPhoneNumViewController *vc = [[SAMCConfirmPhoneNumViewController alloc] init];
    vc.signupOperation = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginViaSMS:(id)sender
{
}

- (void)changeLoginMode:(id)sender
{
    SAMCAccountLoginViewController *vc = [[SAMCAccountLoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - textField
- (void)textFieldEditingChanged:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = SAMC_COLOR_INK;
        _tipLabel.text = @"Login by Mobile";
    }
    return _tipLabel;
}

- (SAMCTextField *)phoneTextField
{
    if (_phoneTextField == nil) {
        _phoneTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
        [_phoneTextField.leftButton setTitle:self.countryCode?:@"+1" forState:UIControlStateNormal];
        [_phoneTextField.leftButton setTitleColor:SAMC_COLOR_INK forState:UIControlStateNormal];
        [_phoneTextField.leftButton setTitleColor:SAMC_COLOR_INK_HINT forState:UIControlStateHighlighted];
        [_phoneTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneTextField.rightTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_phoneTextField.rightTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        _phoneTextField.splitLabel.backgroundColor = SAMC_COLOR_INK_HINT;
        _phoneTextField.rightTextField.textColor = SAMC_COLOR_INK;
        _phoneTextField.rightTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your phone number" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_INK_HINT,NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        self.phoneTextField.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _phoneTextField;
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
        [_passwordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
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

- (UIButton *)changeLoginModeButton
{
    if (_changeLoginModeButton == nil) {
        _changeLoginModeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _changeLoginModeButton.exclusiveTouch = YES;
        _changeLoginModeButton.backgroundColor = [UIColor clearColor];
        [_changeLoginModeButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
        [_changeLoginModeButton setTitleColor:SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5) forState:UIControlStateHighlighted];
        _changeLoginModeButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_changeLoginModeButton setTitle:@"Change Login Mode" forState:UIControlStateNormal];
        [_changeLoginModeButton addTarget:self action:@selector(changeLoginMode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeLoginModeButton;
}

@end
