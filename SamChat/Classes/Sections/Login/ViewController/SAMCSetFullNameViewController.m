//
//  SAMCSetFullNameViewController.m
//  SamChat
//
//  Created by HJ on 11/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSetFullNameViewController.h"
#import "SAMCTextField.h"
#import "SAMCAccountManager.h"
#import "SAMCDeviceUtil.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCPreferenceManager.h"
#import "SAMCUserManager.h"
#import "SAMCPadImageView.h"
#import "SAMCStepperView.h"
#import "SAMCWebViewController.h"
#import "NSString+SAMC.h"
#import "TTTAttributedLabel.h"

@interface SAMCSetFullNameViewController ()<TTTAttributedLabelDelegate>

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *verifyCode;

@property (nonatomic, strong) SAMCStepperView *stepperView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *fullnameTextField;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) TTTAttributedLabel *termsLabel;

@end

@implementation SAMCSetFullNameViewController

- (instancetype)initWithCountryCode:(NSString *)countryCode phone:(NSString *)phone code:(NSString *)code
{
    self = [super init];
    if (self) {
        _countryCode = countryCode;
        _phoneNumber = phone;
        _verifyCode = code;
    }
    return self;
}

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
//    [self.fullnameTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Sign Up";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self.view addSubview:self.stepperView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.fullnameTextField];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.termsLabel];
    
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
    
    [self.fullnameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(20);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(40);
        make.right.equalTo(self.view).with.offset(-40);
        make.top.equalTo(self.fullnameTextField.mas_bottom).with.offset(20);
    }];

    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-60);
    }];
    
    [self.termsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20);
        make.right.equalTo(self.view).with.offset(-20);
        make.bottom.equalTo(self.view).with.offset(-20);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Action
- (void)fullnameTextFieldDidChangedEditing:(id)sender
{
    NSString *fullname = self.fullnameTextField.text;
    self.doneButton.enabled = [fullname samc_isValidFullname];
}

- (void)fullnameTextFieldEditingDidEndOnExit
{
    if (self.doneButton.enabled) {
        [self signup:nil];
    }
}

- (void)signup:(id)sender
{
    NSString *fullname = self.fullnameTextField.text;
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"signing up" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCAccountManager sharedManager] registerWithCountryCode:self.countryCode cellPhone:self.phoneNumber verifyCode:self.verifyCode fullname:fullname completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            if (error.code == SAMCServerErrorNetEaseLoginFailed) {
                [wself setupLoginViewControllerWithToast:@"register success, login now"];
            } else {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            }
            return;
        }
        extern NSString *SAMCLoginNotification;
        [[NSNotificationCenter defaultCenter] postNotificationName:SAMCLoginNotification object:nil userInfo:nil];
    }];
}

- (void)setupLoginViewControllerWithToast:(NSString *)toast
{
    // TODO: setup login vc
    //    [SAMCPreferenceManager sharedManager].currentUserMode = SAMCUserModeTypeCustom;
    //    SAMCLoginViewController *vc = [[SAMCLoginViewController alloc] init];
    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    //    nav.navigationBar.translucent = NO;
    //    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //    window.rootViewController = nav;
    //    [window makeToast:toast duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSString *urlStr = [url absoluteString];
    if([urlStr hasPrefix:@"samchat"]){
        SAMCWebViewController *vc = [[SAMCWebViewController alloc] initWithTitle:@"User Agreement" htmlName:@"terms"];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-60);
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
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = SAMC_COLOR_INK;
        _tipLabel.text = @"Enter your full name";
    }
    return _tipLabel;
}

- (UITextField *)fullnameTextField
{
    if (_fullnameTextField == nil) {
        _fullnameTextField = [[UITextField alloc] init];
        _fullnameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _fullnameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _fullnameTextField.layer.cornerRadius = 6.0f;
        _fullnameTextField.backgroundColor = [UIColor whiteColor];
        _fullnameTextField.textColor = SAMC_COLOR_INK;
        _fullnameTextField.font = [UIFont systemFontOfSize:17.0f];
        _fullnameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Full name" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_INK_HINT ,NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        _fullnameTextField.returnKeyType = UIReturnKeyNext;
        [_fullnameTextField addTarget:self action:@selector(fullnameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_fullnameTextField addTarget:self action:@selector(fullnameTextFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
        
        _fullnameTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_username"]];
        _fullnameTextField.leftViewMode = UITextFieldViewModeAlways;
        
        SAMCPadImageView *rightView = [[SAMCPadImageView alloc] initWithImage:nil];
        _fullnameTextField.rightView = rightView;
        _fullnameTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _fullnameTextField;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = [UIFont systemFontOfSize:15.0f];
        _detailLabel.textColor = SAMC_COLOR_BODY_MID;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.text = @"Enter your full name so others can recognize you";
    }
    return _detailLabel;
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
        [_doneButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (TTTAttributedLabel *)termsLabel
{
    if (_termsLabel == nil) {
        _termsLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _termsLabel.font = [UIFont systemFontOfSize:13.0];
        _termsLabel.textColor = SAMC_COLOR_INGRABLUE;
        _termsLabel.textAlignment = NSTextAlignmentCenter;
        _termsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _termsLabel.numberOfLines = 0;
        _termsLabel.delegate = self;
        
        UIFont *font = [UIFont boldSystemFontOfSize:13.0];
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFloat fontSize = font.pointSize;
        CTFontRef fontRef = CTFontCreateWithName(fontName, fontSize, NULL);
        
        NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
        [linkAttributes setValue:(__bridge id)SAMC_COLOR_INGRABLUE.CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
        _termsLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName:(__bridge id)SAMC_COLOR_INK.CGColor,
                                       (id)kCTFontAttributeName: (__bridge id)fontRef};
        _termsLabel.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:(__bridge id)(SAMCUIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5)).CGColor};
        
        _termsLabel.text = @"Tapping \"Confirm\" means you accept the User Agreement";
        
        NSRange range = [_termsLabel.text rangeOfString:@"User Agreement"];
        [_termsLabel addLinkToURL:[NSURL URLWithString:@"samchat://terms"] withRange:range];
    }
    return _termsLabel;
}


@end
