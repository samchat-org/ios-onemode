//
//  SAMCFullNameSettingViewController.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCFullNameSettingViewController.h"
#import "NIMCommonTableDelegate.h"
#import "NIMCommonTableData.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NSString+SAMC.h"
#import "SAMCAccountManager.h"
#import "SAMCSettingManager.h"
#import "SAMCServerAPIMacro.h"

@interface SAMCFullNameSettingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NIMCommonTableDelegate *delegator;
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, assign) NSInteger inputLimit;
@property (nonatomic, copy) NSString *fullname;

@end

@implementation SAMCFullNameSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _inputLimit = 13;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpNav];
    __weak typeof(self) wself = self;
    SAMCUser *me = [SAMCAccountManager sharedManager].currentUser;
    self.fullname = me.userInfo.username;
    [self buildData];
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    [self.tableView reloadData];
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        for (UIView *subView in cell.subviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                [subView becomeFirstResponder];
                break;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpNav
{
    self.navigationItem.title = @"Full Name";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem.tintColor = SAMC_COLOR_INGRABLUE;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)onDone:(id)sender
{
    [self.view endEditing:YES];
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    NSDictionary *profileDict = @{SAMC_USERNAME:self.fullname};
    [[SAMCSettingManager sharedManager] updateProfile:profileDict completion:^(NSError * _Nullable error) {
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
                                      Title         : @"Full Name",
                                      ExtraInfo     : self.fullname,
                                      CellClass     : @"NTESTextSettingCell",
                                      RowHeight     : @(50),
                                      },
                                  ],
                          FooterTitle:@"Enter your full name so others can recognize you."
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
    self.fullname = textField.text;
    self.navigationItem.rightBarButtonItem.enabled = [self.fullname samc_isValidFullname];
}

@end
