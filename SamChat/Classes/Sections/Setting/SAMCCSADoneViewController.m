//
//  SAMCCSADoneViewController.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSADoneViewController.h"
#import "SAMCGradientButton.h"
#import "SVProgressHUD.h"

@interface SAMCCSADoneViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *welcomeLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) SAMCGradientButton *startButton;

@end

@implementation SAMCCSADoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_INK;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.welcomeLabel];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.startButton];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.top.equalTo(self.view).with.offset(30);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY);
    }];
    
    [self.welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(48);
        make.right.equalTo(self.view).with.offset(-48);
        make.top.equalTo(self.view.mas_centerY);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(48);
        make.right.equalTo(self.view).with.offset(-48);
        make.top.equalTo(self.welcomeLabel.mas_bottom).with.offset(20);
    }];
    
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).with.offset(-20);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)touchGetStarted:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:NULL];
}

#pragma mark - lazy load
- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"Service Profile Created";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    }
    return _titleLabel;
}

- (UIImageView *)logoImageView
{
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"img_BKG_signin"];
    }
    return _logoImageView;
}

- (UILabel *)welcomeLabel
{
    if (_welcomeLabel == nil) {
        _welcomeLabel = [[UILabel alloc] init];
        _welcomeLabel.text = @"Welcome to Your Service Profile";
        _welcomeLabel.textColor = [UIColor whiteColor];
        _welcomeLabel.numberOfLines = 0;
        _welcomeLabel.textAlignment = NSTextAlignmentCenter;
        _welcomeLabel.font = [UIFont systemFontOfSize:28.0f];
    }
    return _welcomeLabel;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"You are now a service provider on Samchat! Start selling your service now!";
        _tipLabel.textColor = UIColorFromRGBA(0xFFFFFF, 0.6);
        _tipLabel.numberOfLines = 0;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (SAMCGradientButton *)startButton
{
    if (_startButton == nil) {
        _startButton = [[SAMCGradientButton alloc] init];
        [_startButton setTitle:@"Show Me Around" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _startButton.gradientLayer.colors = @[(__bridge id)SAMC_COLOR_LIGHTBLUE_GRADIENT_DARK.CGColor,(__bridge id)SAMC_COLOR_LIGHTBLUE_GRADIENT_LIGHT.CGColor];
        _startButton.gradientLayer.cornerRadius = 20.0f;
        _startButton.layer.cornerRadius = 20.0f;
        [_startButton addTarget:self action:@selector(touchGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

@end
