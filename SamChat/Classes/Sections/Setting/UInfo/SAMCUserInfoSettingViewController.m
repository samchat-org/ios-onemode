//
//  SAMCUserInfoSettingViewController.m
//  SamChat
//
//  Created by HJ on 11/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SAMCFullNameSettingViewController.h"
#import "SAMCSamChatIdSettingViewController.h"
#import "NTESUserUtil.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIImage+NTES.h"
#import "NTESFileLocationHelper.h"
#import "NIMWebImageManager.h"
#import "SAMCSettingAvatarView.h"
#import "SAMCAccountManager.h"

@interface SAMCUserInfoSettingViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NIMCommonTableDelegate *delegator;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy)   NSArray *data;

@end

@implementation SAMCUserInfoSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"My Profile";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoHasUpdatedNotification:)
                                                 name:NIMKitUserInfoHasUpdatedNotification
                                               object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildData{
    SAMCUser *me = [SAMCAccountManager sharedManager].currentUser;
    
    SAMCSettingAvatarView *headerView = [[SAMCSettingAvatarView alloc] initWithFrame:CGRectMake(0, 0, 0, 140)];
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:me.userId];
    [headerView refreshData:info];
    [headerView.avatarView addTarget:self action:@selector(onTouchPortrait:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerView;
    
    NSArray *data = @[
                      @{
                          HeaderHeight:@(0.01),
                          RowContent :@[
                                  @{
                                      Title      :@"Name",
                                      DetailTitle:me.userInfo.username.length ? me.userInfo.username : @"",
                                      CellAction :@"onTouchNameSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES),
                                      },
                                  @{
                                      Title      :@"SamChat ID",
                                      DetailTitle:me.userInfo.samchatId.length ? me.userInfo.samchatId : @"Not Set",
                                      CellAction :@"onTouchSamChatIdSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :@"Password",
                                      CellAction :@"onTouchPasswordSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :@"Location",
                                      DetailTitle:me.userInfo.address.length ? me.userInfo.address : @"",
                                      CellAction :@"onTouchLocationSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}


- (void)refresh
{
    [self buildData];
    [self.tableView reloadData];
}

- (void)onTouchPortrait:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"设置头像" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册", nil];
        [sheet showInView:self.view completionHandler:^(NSInteger index) {
            switch (index) {
                case 0:
                    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                    break;
                case 1:
                    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                default:
                    break;
            }
        }];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"设置头像" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册", nil];
        [sheet showInView:self.view completionHandler:^(NSInteger index) {
            switch (index) {
                case 0:
                    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate      = self;
    picker.sourceType    = type;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)onTouchNameSetting:(id)sender
{
    SAMCFullNameSettingViewController *vc = [[SAMCFullNameSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchSamChatIdSetting:(id)sender
{
    SAMCSamChatIdSettingViewController *vc = [[SAMCSamChatIdSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchPasswordSetting:(id)sender
{
}

- (void)onTouchLocationSetting:(id)sender
{
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - onUserInfoHasUpdatedNotification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSArray *userInfos = userInfo[NIMKitInfoKey];
    if ([userInfos containsObject:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        [self refresh];
    }
}



#pragma mark - Private
- (void)uploadImage:(UIImage *)image{
    UIImage *imageForAvatarUpload = [image imageForAvatarUpload];
    NSString *fileName = [NTESFileLocationHelper genFilenameWithExt:@"jpg"];
    NSString *filePath = [[NTESFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:fileName];
    NSData *data = UIImageJPEGRepresentation(imageForAvatarUpload, 1.0);
    BOOL success = data && [data writeToFile:filePath atomically:YES];
    __weak typeof(self) wself = self;
    if (success) {
        [SVProgressHUD show];
        [[NIMSDK sharedSDK].resourceManager upload:filePath progress:nil completion:^(NSString *urlString, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error && wself) {
                [[NIMSDK sharedSDK].userManager updateMyUserInfo:@{@(NIMUserInfoUpdateTagAvatar):urlString} completion:^(NSError *error) {
                    if (!error) {
                        [[NIMWebImageManager sharedManager] saveImageToCache:imageForAvatarUpload forURL:[NSURL URLWithString:urlString]];
                        [wself refresh];
                    }else{
                        [wself.view makeToast:@"设置头像失败，请重试"
                                     duration:2
                                     position:CSToastPositionCenter];
                    }
                }];
            }else{
                [wself.view makeToast:@"图片上传失败，请重试"
                             duration:2
                             position:CSToastPositionCenter];
            }
        }];
    }else{
        [self.view makeToast:@"图片保存失败，请重试"
                    duration:2
                    position:CSToastPositionCenter];
    }
}

#pragma mark - 旋转处理 (iOS7)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

@end
