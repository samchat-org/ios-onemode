//
//  SAMCAccountLoginViewController.m
//  SamChat
//
//  Created by HJ on 11/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAccountLoginViewController.h"
#import "SAMCPadImageView.h"
#import "SVProgressHUD.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"

@interface SAMCAccountLoginViewController ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgetPWDButton;

@end

@implementation SAMCAccountLoginViewController

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
    [self.view addSubview:self.accountTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.forgetPWDButton];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(22);
    }];
    
    [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(20);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.accountTextField.mas_bottom).with.offset(20);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.passwordTextField.mas_bottom).with.offset(20);
    }];
    
    [self.forgetPWDButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.loginButton.mas_bottom).with.offset(20);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Action
- (void)touchNext:(id)sender
{
    [self.passwordTextField becomeFirstResponder];
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
    [_accountTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    NSString *account = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __weak typeof(self) wself = self;
    [[SAMCAccountManager sharedManager] loginWithAccount:account password:password completion:^(NSError * _Nullable error) {
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
        _tipLabel.text = @"Login with SamChat ID";
    }
    return _tipLabel;
}

- (UITextField *)accountTextField
{
    if (_accountTextField == nil) {
        _accountTextField = [[UITextField alloc] init];
        _accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _accountTextField.layer.cornerRadius = 6.0f;
        _accountTextField.backgroundColor = [UIColor whiteColor];
        _accountTextField.textColor = SAMC_COLOR_INK;
        _accountTextField.font = [UIFont systemFontOfSize:17.0f];
        _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SamChat ID" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_INK_HINT,NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        _accountTextField.returnKeyType = UIReturnKeyNext;
        [_accountTextField addTarget:self action:@selector(touchNext:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_accountTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_accountTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        
        _accountTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_username"]];
        _accountTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _accountTextField;
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

@end
