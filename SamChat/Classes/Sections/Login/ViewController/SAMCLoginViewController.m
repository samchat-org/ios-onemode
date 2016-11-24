//
//  SAMCLoginViewController.m
//  SamChat
//
//  Created by HJ on 11/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCLoginViewController.h"
#import "SAMCGradientButton.h"
#import "SAMCConfirmPhoneNumViewController.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESLogManager.h"
#import "SAMCMobileLoginViewController.h"

@interface SAMCLoginViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) SAMCGradientButton *signupButton;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation SAMCLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_INK;
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.signupButton];
    [self.view addSubview:self.loginButton];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [self.signupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(32);
        make.right.equalTo(self.view.mas_centerX).with.offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-60);
        make.height.mas_equalTo(40);
    }];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_centerX).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-32);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-60);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Action
- (void)signup:(id)sender
{
    SAMCConfirmPhoneNumViewController *vc = [[SAMCConfirmPhoneNumViewController alloc] init];
    vc.signupOperation = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)login:(id)sender
{
    SAMCMobileLoginViewController *vc = [[SAMCMobileLoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareShowLog:(UILongPressGestureRecognizer *)gesuture{
    if (gesuture.state == UIGestureRecognizerStateBegan) {
        __weak typeof(self) wself = self;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看SDK日志",@"查看Demo日志", nil];
        [actionSheet showInView:self.view completionHandler:^(NSInteger index) {
            switch (index) {
                case 0:
                    [wself showSDKLog];
                    break;
                case 1:
                    [wself showDemoLog];
                    break;
                default:
                    break;
            }
        }];
    }
}

#pragma mark - Private
- (void)showSDKLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoLog{
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

#pragma mark - lazy load
- (UIImageView *)logoImageView
{
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_BKG_Launch"]];
    }
    return _logoImageView;
}

- (SAMCGradientButton *)signupButton
{
    if (_signupButton == nil) {
        _signupButton = [[SAMCGradientButton alloc] initWithFrame:CGRectZero];
        _signupButton.exclusiveTouch = YES;
        _signupButton.layer.cornerRadius = 20.0f;
        _signupButton.layer.masksToBounds = YES;
        _signupButton.gradientLayer.cornerRadius = 20.0f;
        _signupButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [_signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signupButton setTitleColor:SAMC_COLOR_WHITE_HINT forState:UIControlStateHighlighted];
        _signupButton.gradientLayer.colors = @[(__bridge id)SAMC_COLOR_GRASSFIELD_GRADIENT_DARK.CGColor,
                                               (__bridge id)SAMC_COLOR_GRASSFIELD_GRADIENT_LIGHT.CGColor];
        [_signupButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signupButton;
}

- (UIButton *)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] init];
        _loginButton.exclusiveTouch = YES;
        _loginButton.layer.cornerRadius = 20.0f;
        _loginButton.layer.masksToBounds = YES;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [_loginButton setTitleColor:SAMC_COLOR_INK forState:UIControlStateNormal];
        [_loginButton setTitleColor:SAMC_COLOR_INK_HINT forState:UIControlStateHighlighted];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_grey_active"] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_grey_pressed"] forState:UIControlStateHighlighted];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_grey_inactive"] forState:UIControlStateDisabled];
        [_loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *longPressOnLoginBtn = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(prepareShowLog:)];
        [_loginButton addGestureRecognizer:longPressOnLoginBtn];
    }
    return _loginButton;
}

@end
