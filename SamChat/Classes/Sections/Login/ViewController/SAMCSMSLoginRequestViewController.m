//
//  SAMCSMSLoginRequestViewController.m
//  SamChat
//
//  Created by HJ on 11/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSMSLoginRequestViewController.h"
#import "SAMCCountryCodeViewController.h"
#import "SAMCSMSLoginViewController.h"
#import "SAMCTextField.h"
#import "NSString+SAMC.h"
#import "SVProgressHUD.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"

@interface SAMCSMSLoginRequestViewController ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation SAMCSMSLoginRequestViewController

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
    [self.view addSubview:self.nextButton];
    
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
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.phoneTextField.mas_bottom).with.offset(20);
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

- (void)next:(id)sender
{
    NSString *countryCode = _phoneTextField.leftButton.titleLabel.text;
    countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *cellPhone = [_phoneTextField.rightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCAccountManager sharedManager] loginCodeRequestWithCountryCode:countryCode cellPhone:cellPhone completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        SAMCSMSLoginViewController *vc = [[SAMCSMSLoginViewController alloc] initWithCountryCode:countryCode cellPhone:cellPhone];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - textField
- (void)textFieldEditingChanged:(UITextField *)textField
{
    self.nextButton.enabled = [textField.text samc_isValidCellphone];
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
        _tipLabel.text = @"Login via SMS";
    }
    return _tipLabel;
}

- (SAMCTextField *)phoneTextField
{
    if (_phoneTextField == nil) {
        _phoneTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
        [_phoneTextField.leftButton setTitle:@"+1" forState:UIControlStateNormal];
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

- (UIButton *)nextButton
{
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _nextButton.exclusiveTouch = YES;
        _nextButton.layer.cornerRadius = 20.0f;
        _nextButton.layer.masksToBounds = YES;
        _nextButton.enabled = NO;
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton setTitleColor:SAMC_COLOR_WHITE_HINT forState:UIControlStateHighlighted];
        [_nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

@end
