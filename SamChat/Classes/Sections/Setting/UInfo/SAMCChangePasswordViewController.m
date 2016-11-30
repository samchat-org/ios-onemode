//
//  SAMCChangePasswordViewController.m
//  SamChat
//
//  Created by HJ on 11/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCChangePasswordViewController.h"
#import "SAMCPadImageView.h"
#import "NSString+SAMC.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCAccountManager.h"

@interface SAMCChangePasswordViewController ()

@property (nonatomic, strong) UITextField *currentPasswordTextField;
@property (nonatomic, strong) UITextField *changePasswordTextField;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpaceConstraint;

@end

@implementation SAMCChangePasswordViewController

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
    [self.currentPasswordTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Change Password";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self setupNavItem];
    
    [self.view addSubview:self.currentPasswordTextField];
    [self.view addSubview:self.changePasswordTextField];
    [self.view addSubview:self.doneButton];
    
    [self.currentPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.top.equalTo(self.view).with.offset(16);
        make.height.equalTo(@40);
    }];
    
    [self.changePasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.top.equalTo(self.currentPasswordTextField.mas_bottom).with.offset(10);
        make.height.equalTo(@40);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).with.offset(-20);
    }];
}

- (void)setupNavItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onCancel:)];
    if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    } else {
        self.navigationItem.rightBarButtonItem.tintColor = SAMC_COLOR_INGRABLUE;
    }
}

#pragma mark - Action
- (void)onCancel:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onDone:(id)sender
{
    NSString *currentPWD = _currentPasswordTextField.text;
    NSString *changePWD = _changePasswordTextField.text;
   
    [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] updatePWDFrom:currentPWD to:changePWD completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
        } else {
            [wself.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)textFieldEditingDidEndOnExit:(UITextField *)textField
{
    if ([textField isEqual:_currentPasswordTextField]) {
        [_changePasswordTextField becomeFirstResponder];
    } else {
        [self onDone:nil];
    }
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    NSString *currentPassword = _currentPasswordTextField.text;
    NSString *changePassword = _changePasswordTextField.text;
    _doneButton.enabled = [currentPassword samc_isValidPassword] && [changePassword samc_isValidPassword];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
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
                             make.bottom.equalTo(self.view).with.offset(-keyboardHeight-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view).with.offset(-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (UITextField *)currentPasswordTextField
{
    if (_currentPasswordTextField == nil) {
        _currentPasswordTextField = [[UITextField alloc] init];
        _currentPasswordTextField.secureTextEntry = YES;
        _currentPasswordTextField.backgroundColor = [UIColor whiteColor];
        _currentPasswordTextField.layer.cornerRadius = 6.0f;
        _currentPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Current password"
                                                                                          attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
        _currentPasswordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _currentPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
        _currentPasswordTextField.returnKeyType = UIReturnKeyNext;
        [_currentPasswordTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_currentPasswordTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_currentPasswordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _currentPasswordTextField;
}

- (UITextField *)changePasswordTextField
{
    if (_changePasswordTextField == nil) {
        _changePasswordTextField = [[UITextField alloc] init];
        _changePasswordTextField.secureTextEntry = YES;
        _changePasswordTextField.backgroundColor = [UIColor whiteColor];
        _changePasswordTextField.layer.cornerRadius = 6.0f;
        _changePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New password"
                                                                                          attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
        _changePasswordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _changePasswordTextField.leftViewMode = UITextFieldViewModeAlways;
        _changePasswordTextField.returnKeyType = UIReturnKeyDone;
        [_changePasswordTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_changePasswordTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_changePasswordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _changePasswordTextField;
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.layer.cornerRadius = 20.0f;
        _doneButton.layer.masksToBounds = YES;
        _doneButton.enabled = false;
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

@end
