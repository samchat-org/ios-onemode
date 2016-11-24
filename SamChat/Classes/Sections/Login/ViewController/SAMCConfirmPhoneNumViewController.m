//
//  SAMCConfirmPhoneNumViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConfirmPhoneNumViewController.h"
#import "SAMCCountryCodeViewController.h"
#import "SAMCTextField.h"
#import "SAMCConfirmPhoneCodeViewController.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCStepperView.h"
#import "NSString+SAMC.h"

@interface SAMCConfirmPhoneNumViewController ()

@property (nonatomic, strong) SAMCStepperView *stepperView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, copy) NSString *phoneNumber;

@end

@implementation SAMCConfirmPhoneNumViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.phoneTextField.rightTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.sendButton];
    
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
    
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(30);
        make.height.equalTo(@40);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(48);
        make.right.equalTo(self.view).with.offset(-48);
        make.top.equalTo(self.phoneTextField.mas_bottom).with.offset(20);
    }];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
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

- (void)phoneNumberEditingChanged:(id)sender
{
    NSString *phone = self.phoneTextField.rightTextField.text;
    _sendButton.enabled = [phone samc_isValidCellphone];
}

- (void)sendConfirmationCode:(UIButton *)sender
{
    self.phoneNumber = self.phoneTextField.rightTextField.text;
    NSString *countryCode = self.phoneTextField.leftButton.titleLabel.text;
    self.countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    
    void (^completionBlock)(NSError *) = ^(NSError * _Nullable error){
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [wself pushToConfirmPhoneCodeView];
    };
    if (self.isSignupOperation) {
        [[SAMCAccountManager sharedManager] registerCodeRequestWithCountryCode:self.countryCode
                                                                     cellPhone:self.phoneNumber
                                                                    completion:completionBlock];
    } else {
        [[SAMCAccountManager sharedManager] findPWDCodeRequestWithCountryCode:self.countryCode
                                                                    cellPhone:self.phoneNumber
                                                                   completion:completionBlock];
    }
}

- (void)pushToConfirmPhoneCodeView
{
    SAMCConfirmPhoneCodeViewController *vc = [[SAMCConfirmPhoneCodeViewController alloc] init];
    vc.signupOperation = self.isSignupOperation;
    vc.countryCode = self.countryCode;
    vc.phoneNumber = self.phoneNumber;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardHeight-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (SAMCStepperView *)stepperView
{
    if (_stepperView == nil) {
        _stepperView = [[SAMCStepperView alloc] initWithFrame:CGRectZero step:1 color:SAMC_COLOR_GREEN];
    }
    return _stepperView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _tipLabel.textColor = SAMC_COLOR_INK;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"Enter your mobile";
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
        [_phoneTextField.rightTextField addTarget:self action:@selector(phoneNumberEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        _phoneTextField.splitLabel.backgroundColor = SAMC_COLOR_INK_HINT;
        _phoneTextField.rightTextField.textColor = SAMC_COLOR_INK;
        _phoneTextField.rightTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your phone number" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_INK_HINT,NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        self.phoneTextField.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _phoneTextField;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = [UIFont systemFontOfSize:15.0f];
        _detailLabel.textColor = SAMC_COLOR_BODY_MID;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.text = @"A confirmation code will be sent to the phone number your entered via SMS";
    }
    return _detailLabel;
}

- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _sendButton.exclusiveTouch = YES;
        _sendButton.layer.cornerRadius = 20.0f;
        _sendButton.layer.masksToBounds = YES;
        _sendButton.enabled = NO;
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_sendButton setTitle:@"Send Confirmation Code" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setTitleColor:SAMC_COLOR_WHITE_HINT forState:UIControlStateHighlighted];
        [_sendButton addTarget:self action:@selector(sendConfirmationCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@end
