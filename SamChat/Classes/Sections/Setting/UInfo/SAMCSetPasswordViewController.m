//
//  SAMCSetPasswordViewController.m
//  SamChat
//
//  Created by HJ on 12/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSetPasswordViewController.h"
#import "NIMCommonTableDelegate.h"
#import "NIMCommonTableData.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NSString+SAMC.h"
#import "SAMCAccountManager.h"
#import "SAMCSettingManager.h"
#import "SAMCServerAPIMacro.h"
#import "UIView+NIM.h"

@interface SAMCSetPasswordViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NIMCommonTableDelegate *delegator;
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, assign) NSInteger inputLimit;
@property (nonatomic, copy) NSString *password;

@end

@implementation SAMCSetPasswordViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _inputLimit = 32;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpNav];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;

    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        for (UIView *subView in cell.subviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                [subView becomeFirstResponder];
                break;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTextFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpNav
{
    self.navigationItem.title = @"Set Password";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onDone:)];
    if ([SAMCAccountManager sharedManager].isCurrentUserServicer) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    } else {
        self.navigationItem.rightBarButtonItem.tintColor = SAMC_COLOR_INGRABLUE;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)onDone:(id)sender
{
    [self.view endEditing:YES];
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] updatePWDFrom:@"" to:self.password completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
        } else {
            [wself.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)buildData
{
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title         : @"Set SamChat password",
                                      CellClass     : @"NTESTextSettingCell",
                                      RowHeight     : @(50),
                                      },
                                  ],
                          FooterTitle:@"Password not set for your current ID. Set a password first and log out again."
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 如果是删除键
    if ([string length] == 0 && range.length > 0)
    {
        return YES;
    }
    NSString *genString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.inputLimit && genString.length > self.inputLimit) {
        return NO;
    }
    return YES;
}


- (void)onTextFieldChanged:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    self.password = textField.text;
    self.navigationItem.rightBarButtonItem.enabled = [self.password samc_isValidPassword];
}

@end
