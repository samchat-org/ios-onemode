//
//  SAMCSetPasswordViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSetPasswordViewController.h"
#import "SAMCTextField.h"
#import "SAMCAccountManager.h"
#import "SAMCDeviceUtil.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCPreferenceManager.h"
#import "SAMCLoginViewController.h"
#import "SAMCUserManager.h"
#import "SAMCPadImageView.h"
#import "SAMCStepperView.h"
#import "SAMCWebViewController.h"
#import "NSString+SAMC.h"

@interface SAMCSetPasswordViewController ()

@property (nonatomic, strong) SAMCStepperView *stepperView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation SAMCSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Reset Password";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self.view addSubview:self.stepperView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.doneButton];
    
    [self.stepperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@72);
        make.height.equalTo(@12);
        make.top.equalTo(self.view).with.offset(20);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.stepperView.mas_bottom).with.offset(22);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(20);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Action
- (void)touchDone:(UIButton *)sender
{
    if (self.doneButton.enabled) {
        [self resetPassword:nil];
    }
}

- (void)resetPassword:(id)sender
{
    NSString *password = self.passwordTextField.text;
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"resetting password" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCAccountManager sharedManager] findPWDUpdateWithCountryCode:self.countryCode cellPhone:self.phoneNumber verifyCode:self.verifyCode password:password completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [wself setupLoginViewControllerWithToast:@"reset password success, login now"];
    }];
}

- (void)setupLoginViewControllerWithToast:(NSString *)toast
{
//    [SAMCPreferenceManager sharedManager].currentUserMode = SAMCUserModeTypeCustom;
//    SAMCLoginViewController *vc = [[SAMCLoginViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    nav.navigationBar.translucent = NO;
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    window.rootViewController = nav;
//    [window makeToast:toast duration:2.0 position:CSToastPositionCenter];
}

- (void)showPassword:(UIButton *)sender
{
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    UIButton *showPWDButton = (UIButton *)self.passwordTextField.rightView;
    NSString *showImageName = self.passwordTextField.secureTextEntry ? @"ico_showpw_light_dim" : @"ico_showpw_light_full";
    [showPWDButton setImage:[UIImage imageNamed:showImageName] forState:UIControlStateNormal];
    // fix cursor location unchanged issue
    NSString *tempString = self.passwordTextField.text;
    self.passwordTextField.text = @"";
    self.passwordTextField.text = tempString;
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardHeight-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (SAMCStepperView *)stepperView
{
    if (_stepperView == nil) {
        _stepperView = [[SAMCStepperView alloc] initWithFrame:CGRectZero step:3 color:SAMC_COLOR_GREEN];
    }
    return _stepperView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _tipLabel.textColor = SAMC_COLOR_INK;
        _tipLabel.text = @"Enter your new password";
    }
    return _tipLabel;
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
        [_passwordTextField addTarget:self action:@selector(passwordTextFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
        
        _passwordTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _passwordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton *showPWDButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [showPWDButton setImage:[UIImage imageNamed:@"ico_showpw_light_dim"] forState:UIControlStateNormal];
        showPWDButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [showPWDButton addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
        self.passwordTextField.rightView = showPWDButton;
        self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _passwordTextField;
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.exclusiveTouch = YES;
        _doneButton.enabled = NO;
        _doneButton.layer.cornerRadius = 20.f;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        [_doneButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitleColor:SAMC_COLOR_WHITE_HINT forState:UIControlStateHighlighted];
        [_doneButton addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}


#pragma mark -
- (void)passwordTextFieldDidChangedEditing:(id)sender
{
    self.doneButton.enabled = [self.passwordTextField.text samc_isValidPassword];
}

@end
