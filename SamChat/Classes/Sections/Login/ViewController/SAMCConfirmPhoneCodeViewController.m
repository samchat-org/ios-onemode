//
//  SAMCConfirmPhoneCodeViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConfirmPhoneCodeViewController.h"
#import "SAMCTextField.h"
#import "SAMCPhoneCodeView.h"
#import "SAMCSetPasswordViewController.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCStepperView.h"
#import "UIButton+SAMC.h"
#import "SAMCSetFullNameViewController.h"

@interface SAMCConfirmPhoneCodeViewController ()<SAMCPhoneCodeViewDelegate>

@property (nonatomic, strong) SAMCStepperView *stepperView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCPhoneCodeView *phoneCodeView;
@property (nonatomic, strong) UILabel *splitLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *resendButton;
@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation SAMCConfirmPhoneCodeViewController

- (void)viewDidLoad
{
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.phoneCodeView becomeFirstResponder];
}

- (void)setupSubviews
{
    if (self.isSignupOperation) {
        self.navigationItem.title = @"Sign Up";
    } else {
        self.navigationItem.title = @"Reset Password";
    }
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    
    [self.view addSubview:self.stepperView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.phoneCodeView];
    [self.view addSubview:self.splitLabel];
    [self.view addSubview:self.phoneLabel];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.resendButton];
    [self.view addSubview:self.submitButton];
    
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
    
    [self.phoneCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(25);
        make.height.equalTo(@44);
    }];
    
    [self.splitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10);
        make.right.equalTo(self.view).with.offset(-10);
        make.top.equalTo(self.phoneCodeView.mas_bottom).with.offset(20);
        make.height.equalTo(@1);
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.splitLabel.mas_bottom).with.offset(20);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(40);
        make.right.equalTo(self.view).with.offset(-40);
        make.top.equalTo(self.phoneLabel.mas_bottom).with.offset(10);
    }];
    
    [self.resendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.detailLabel.mas_bottom).with.offset(10);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
    
   [self.resendButton startWithCountDownSeconds:60 titleFormat:@"Resend code in %02ld seconds..."];
}

#pragma mark - SAMCPhoneCodeViewDelegate
- (void)phonecodeDidChange:(SAMCPhoneCodeView *)view
{
    self.submitButton.enabled = (view.phoneCode.length == 4);
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.submitButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardHeight-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.submitButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - Action
- (void)resend:(id)sender
{
    // TODO: add resend
    DDLogInfo(@"touch resend button");
}

- (void)submit:(id)sender
{
    NSString *countryCode = self.countryCode;
    NSString *phoneNumber = self.phoneNumber;
    NSString *verifyCode = self.phoneCodeView.phoneCode;
    [SVProgressHUD showWithStatus:@"Verifing" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    void (^completionBlock)(NSError *) = ^(NSError * _Nullable error){
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        UIViewController *vc;
        if (wself.isSignupOperation) {
            vc = [[SAMCSetFullNameViewController alloc] initWithCountryCode:countryCode
                                                                      phone:phoneNumber
                                                                       code:verifyCode];
        } else {
            vc = [[SAMCSetPasswordViewController alloc] initWithCountryCode:countryCode
                                                                      phone:phoneNumber
                                                                       code:verifyCode];
        }
        [self.navigationController pushViewController:vc animated:YES];
    };
    if (self.isSignupOperation) {
        [[SAMCAccountManager sharedManager] registerCodeVerifyWithCountryCode:self.countryCode
                                                                    cellPhone:self.phoneNumber
                                                                   verifyCode:verifyCode
                                                                   completion:completionBlock];
    } else {
        [[SAMCAccountManager sharedManager] findPWDCodeVerifyWithCountryCode:self.countryCode
                                                                   cellPhone:self.phoneNumber
                                                                  verifyCode:verifyCode
                                                                  completion:completionBlock];
    }

}

#pragma mark - lazy load
- (SAMCStepperView *)stepperView
{
    if (_stepperView == nil) {
        _stepperView = [[SAMCStepperView alloc] initWithFrame:CGRectZero step:2 color:SAMC_COLOR_GREEN];
    }
    return _stepperView;
}

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

- (UILabel *)splitLabel
{
    if (_splitLabel == nil) {
        _splitLabel = [[UILabel alloc] init];
        _splitLabel.backgroundColor = SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.1);
    }
    return _splitLabel;
}

- (UILabel *)phoneLabel
{
    if (_phoneLabel == nil) {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.font = [UIFont boldSystemFontOfSize:21.0f];
        _phoneLabel.textColor = SAMC_COLOR_INK;
        _phoneLabel.textAlignment = NSTextAlignmentCenter;
        _phoneLabel.text = [NSString stringWithFormat:@"+%@-%@",self.countryCode,self.phoneNumber];
    }
    return _phoneLabel;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = [UIFont systemFontOfSize:15.0f];
        _detailLabel.textColor = SAMC_COLOR_BODY_MID;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.text = @"A confirmation code has been sent to your phone, enter the code to continue";
    }
    return _detailLabel;
}

- (UIButton *)resendButton
{
    if (_resendButton == nil) {
        _resendButton = [[UIButton alloc] init];
        _resendButton.exclusiveTouch = YES;
        _resendButton.backgroundColor = [UIColor clearColor];
        [_resendButton setTitleColor:SAMC_COLOR_INK forState:UIControlStateNormal];
        [_resendButton setTitleColor:SAMC_COLOR_INK_HINT forState:UIControlStateHighlighted];
        [_resendButton setTitleColor:SAMC_COLOR_INK forState:UIControlStateDisabled];
        [_resendButton setTitle:@"Resend code" forState:UIControlStateNormal];
        [_resendButton addTarget:self action:@selector(resend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resendButton;
}

- (UIButton *)submitButton
{
    if (_submitButton == nil) {
        _submitButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _submitButton.exclusiveTouch = YES;
        _submitButton.layer.cornerRadius = 20.0f;
        _submitButton.layer.masksToBounds = YES;
        _submitButton.enabled = NO;
        [_submitButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_submitButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_submitButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_submitButton setTitle:@"Submit"forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitButton setTitleColor:SAMC_COLOR_WHITE_HINT forState:UIControlStateHighlighted];
        [_submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

@end
