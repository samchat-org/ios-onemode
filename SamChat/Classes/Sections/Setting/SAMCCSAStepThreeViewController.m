//
//  SAMCCSAStepThreeViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepThreeViewController.h"
#import "SAMCTextView.h"
#import "SAMCServerAPIMacro.h"
#import "SVProgressHUD.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SAMCCSADoneViewController.h"

@interface SAMCCSAStepThreeViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCTextView *descriptionTextView;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@end

@implementation SAMCCSAStepThreeViewController

- (instancetype)initWithInformation:(NSMutableDictionary *)information
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _samProsInformation = information;
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
    [self.descriptionTextView becomeFirstResponder];
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
    [self.view addSubview:self.descriptionTextView];
    [self.view addSubview:self.doneButton];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(22);
    }];
    
    [self.descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(20);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)onDone:(id)sender
{
    NSString *serviceDesc = _descriptionTextView.text;
    [self.samProsInformation setObject:serviceDesc forKey:SAMC_SERVICE_DESCRIPTION];
    
    [SVProgressHUD showWithStatus:@"Creating" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] createSamPros:self.samProsInformation completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        SAMCCSADoneViewController *vc = [[SAMCCSADoneViewController alloc] init];
        [wself presentViewController:vc animated:YES completion:^{
            [wself.navigationController popToRootViewControllerAnimated:NO];
        }];
    }];
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

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([_descriptionTextView.text length]) {
        _doneButton.enabled = YES;
    } else {
        _doneButton.enabled = NO;
    }
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"Tell us a bit more about your business or service";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = UIColorFromRGB(0x1B3257);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (SAMCTextView *)descriptionTextView
{
    if (_descriptionTextView == nil) {
        _descriptionTextView = [[SAMCTextView alloc] init];
        _descriptionTextView.placeholder = @"i.e. your specialization, years of experience, how do you work with your client, etc.";
        _descriptionTextView.delegate = self;
    }
    return _descriptionTextView;
}


- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        _doneButton.layer.cornerRadius = 20.0f;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_active"] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_pressed"] forState:UIControlStateHighlighted];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_inactive"] forState:UIControlStateDisabled];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

@end
