//
//  SAMCSPIntroViewController.m
//  SamChat
//
//  Created by HJ on 11/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPIntroViewController.h"
#import "SAMCCSAStepOneViewController.h"

@interface SAMCSPIntroViewController ()

@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation SAMCSPIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.doneButton];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(32);
        make.right.equalTo(self.view).with.offset(-32);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).with.offset(-20);
    }];
}

- (void)createSamPros:(id)sender
{
    SAMCCSAStepOneViewController *vc = [[SAMCCSAStepOneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.layer.cornerRadius = 20.0f;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_active"] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_pressed"] forState:UIControlStateHighlighted];
        [_doneButton setTitle:@"Become a Service Profiver" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(createSamPros:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}


@end
