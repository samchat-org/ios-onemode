//
//  UIViewController+Swizzling.m
//  NIM
//
//  Created by chris on 15/6/15.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import "SVProgressHUD.H"
#import "SwizzlingDefine.h"
#import "UIResponder+NTESFirstResponder.h"
#import "UIView+NTES.h"
#import "UIImage+NTESColor.h"
#import "SAMCAccountManager.h"

@implementation UIViewController (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewWillAppear:), @selector(swizzling_viewWillAppear:));
//        swizzling_exchangeMethod([UIViewController class] ,@selector(viewDidAppear:), @selector(swizzling_viewDidAppear:));
//        swizzling_exchangeMethod([UIViewController class] ,@selector(viewWillDisappear:), @selector(swizzling_viewWillDisappear:));
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewDidLoad),    @selector(swizzling_viewDidLoad));
        swizzling_exchangeMethod([UIViewController class], @selector(initWithNibName:bundle:), @selector(swizzling_initWithNibName:bundle:));
        swizzling_exchangeMethod([UIViewController class], @selector(viewWillLayoutSubviews), @selector(swizzling_viewWillLayoutSubviews));
    });
}

#pragma mark - ViewDidLoad
- (void)swizzling_viewDidLoad{
    if (self.navigationController) {
        NSString *backButtonImageName;
        if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
            backButtonImageName = @"ico_nav_back_dark";
        } else {
            backButtonImageName = @"ico_nav_back_light";
        }
        UIImage *buttonNormal = [[UIImage imageNamed:backButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.navigationController.navigationBar setBackIndicatorImage:buttonNormal];
        [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:buttonNormal];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
    }
    [self swizzling_viewDidLoad];
}


#pragma mark - InitWithNibName:bundle:
//如果希望vchidesBottomBarWhenPushed为NO的话，请在vc init方法之后调用vc.hidesBottomBarWhenPushed = NO;
- (instancetype)swizzling_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    id instance = [self swizzling_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (instance) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return instance;
}

#pragma mark - ViewWillAppear
static char UIFirstResponderViewAddress;

- (void)swizzling_viewWillAppear:(BOOL)animated{
    [self swizzling_viewWillAppear:animated];
    if ((self.parentViewController == self.navigationController) && self.navigationController)
    {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        
        UIColor *barColor;
        UIColor *titleColor;
        if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
            barColor = SAMC_COLOR_NAV_DARK;
            titleColor = [UIColor whiteColor];
        } else {
            barColor = SAMC_COLOR_NAV_LIGHT;
            titleColor = SAMC_COLOR_INK;
        }
        self.navigationController.navigationBar.barTintColor = barColor;
        
        id titleView = self.navigationItem.titleView;
        if ([titleView isKindOfClass:[UILabel class]]) {
            ((UILabel *)titleView).textColor = titleColor;
        }
    }
}

#pragma mark - ViewDidAppear
- (void)swizzling_viewDidAppear:(BOOL)animated{
    [self swizzling_viewDidAppear:animated];
    UIView *view = objc_getAssociatedObject(self, &UIFirstResponderViewAddress);
    [view becomeFirstResponder];
}


#pragma mark - ViewWillDisappear

- (void)swizzling_viewWillDisappear:(BOOL)animated{
    [self swizzling_viewWillDisappear:animated];
    UIView *view = (UIView *)[UIResponder currentFirstResponder];
    if ([view isKindOfClass:[UIView class]] && view.viewController == self) {
        objc_setAssociatedObject(self, &UIFirstResponderViewAddress, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [view resignFirstResponder];
    }else{
        objc_setAssociatedObject(self, &UIFirstResponderViewAddress, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - viewWillLayoutSubviews
-(void)swizzling_viewWillLayoutSubviews
{
    [self swizzling_viewWillLayoutSubviews];
//    id titleView = self.navigationItem.titleView;
//    UILabel *label;
//    if ([titleView isKindOfClass:[UILabel class]]) {
//        label = (UILabel *)titleView;
//        if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
//            label.textColor = [UIColor whiteColor];
//        } else {
//            label.textColor = SAMC_COLOR_INK;
//        }
//    }
}

#pragma mark - Private
- (BOOL)swizzling_isUseClearBar
{
    SEL  sel = NSSelectorFromString(@"useClearBar");
    BOOL use = NO;
    if ([self respondsToSelector:sel]) {
        SuppressPerformSelectorLeakWarning(use = (BOOL)[self performSelector:sel]);
    }
    return use;
}


@end
