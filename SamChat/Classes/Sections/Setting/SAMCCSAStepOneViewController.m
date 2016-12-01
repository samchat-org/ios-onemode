//
//  SAMCCSAStepOneViewController.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepOneViewController.h"
#import "SAMCCSAStepThreeViewController.h"
#import "SAMCSelectLocationViewController.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCPadImageView.h"

@interface SAMCCSAStepOneViewController ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *serviceCategoryTextField;
@property (nonatomic, strong) UITextField *serviceLocationTextField;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@property (nonatomic, strong) NSDictionary *location;

@end

@implementation SAMCCSAStepOneViewController

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
    [self.serviceCategoryTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Create Service Profile"];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self setUpNavItem];

    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.serviceCategoryTextField];
    [self.view addSubview:self.serviceLocationTextField];
    [self.view addSubview:self.nextButton];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(22);
    }];
    
    [self.serviceCategoryTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(20);
    }];
    
    [self.serviceLocationTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.top.equalTo(self.serviceCategoryTextField.mas_bottom).with.offset(20);
    }];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
}

- (void)setUpNavItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onCancel)];
    self.navigationItem.rightBarButtonItem.tintColor = SAMC_COLOR_INGRABLUE;
}

- (void)onCancel
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onNext:(id)sender
{
    NSString *serviceCategory = _serviceCategoryTextField.text;
    [self.samProsInformation setObject:serviceCategory forKey:SAMC_SERVICE_CATEGORY];
    if (self.location) {
        [self.samProsInformation setObject:self.location forKey:SAMC_LOCATION];
    }
    [self pushToNextStepVC];
}

- (void)pushToNextStepVC
{
    SAMCCSAStepThreeViewController *vc = [[SAMCCSAStepThreeViewController alloc] initWithInformation:self.samProsInformation];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    self.nextButton.enabled = [self.serviceCategoryTextField.text length] && [self.serviceLocationTextField.text length];
}

- (void)textFieldEditingDidEndOnExit:(UITextField *)textField
{
    if ([textField isEqual:self.serviceCategoryTextField]) {
        [self.serviceLocationTextField becomeFirstResponder];
    } else {
        [self onNext:nil];
    }
}

- (void)locationTextFieldEditingDidBegin:(id)sender
{
    SAMCSelectLocationViewController *vc = [[SAMCSelectLocationViewController alloc] initWithHideCurrentLocation:YES userMode:SAMCUserModeTypeCustom];
    __weak typeof(self) wself = self;
    vc.selectBlock = ^(NSDictionary *location, BOOL isCurrentLocation){
        if (!isCurrentLocation) {
            wself.location = location;
            wself.serviceLocationTextField.text = location[SAMC_ADDRESS];
        }
        [wself textFieldEditingChanged:wself.serviceLocationTextField];
    };
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
                         [self.nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-keyboardHeight-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
                         }];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (NSMutableDictionary *)samProsInformation
{
    if (_samProsInformation == nil) {
        _samProsInformation = [[NSMutableDictionary alloc] init];
    }
    return _samProsInformation;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"Basic information about your business or service";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = UIColorFromRGB(0x1B3257);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (UITextField *)serviceCategoryTextField
{
    if (_serviceCategoryTextField == nil) {
        _serviceCategoryTextField = [[UITextField alloc] init];
        _serviceCategoryTextField.backgroundColor = [UIColor whiteColor];
        _serviceCategoryTextField.layer.cornerRadius = 5.0f;
        _serviceCategoryTextField.placeholder = @"Business or service category";
        _serviceCategoryTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_category"]];
        _serviceCategoryTextField.leftViewMode = UITextFieldViewModeAlways;
        _serviceCategoryTextField.returnKeyType = UIReturnKeyDone;
        [_serviceCategoryTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_serviceCategoryTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_serviceCategoryTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _serviceCategoryTextField;
}

- (UITextField *)serviceLocationTextField
{
    if (_serviceLocationTextField == nil) {
        _serviceLocationTextField = [[UITextField alloc] init];
        _serviceLocationTextField.backgroundColor = [UIColor whiteColor];
        _serviceLocationTextField.layer.cornerRadius = 5.0f;
        _serviceLocationTextField.placeholder = @"Location";
        _serviceLocationTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_location"]];
        _serviceLocationTextField.leftViewMode = UITextFieldViewModeAlways;
        _serviceLocationTextField.returnKeyType = UIReturnKeyDone;
        [_serviceLocationTextField addTarget:self action:@selector(locationTextFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    }
    return _serviceLocationTextField;
}

- (UIButton *)nextButton
{
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
        _nextButton.layer.cornerRadius = 20.0f;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_active"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_pressed"] forState:UIControlStateHighlighted];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_inactive"] forState:UIControlStateDisabled];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
        _nextButton.enabled = NO;
    }
    return _nextButton;
}

@end
