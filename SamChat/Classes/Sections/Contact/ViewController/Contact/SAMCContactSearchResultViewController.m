//
//  SAMCContactSearchResultViewController.m
//  SamChat
//
//  Created by HJ on 12/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCContactSearchResultViewController.h"
#import "NTESSessionUtil.h"
#import "NTESSessionViewController.h"
#import "NTESContactUtilItem.h"
#import "NTESContactDefines.h"
#import "SAMCGroupedContacts.h"
#import "NTESContactUtilCell.h"
#import "NIMContactDataCell.h"
#import "NTESPersonalCardViewController.h"

@interface SAMCContactSearchResultViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SAMCContactSearchResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableHeaderView = [[UIView alloc] init];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<NTESContactItem> contactItem = (id<NTESContactItem>)self.searchResultData[indexPath.row];
    NSString * friendId = contactItem.userId;
    [self enterPersonalCard:friendId];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NTESContactItem> contactItem = (id<NTESContactItem>)self.searchResultData[indexPath.row];
    return contactItem.uiHeight;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResultData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id contactItem = self.searchResultData[indexPath.row];
    NSString * cellId = [contactItem reuseId];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        Class cellClazz = NSClassFromString([contactItem cellName]);
        cell = [[cellClazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([contactItem showAccessoryView]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([cell isKindOfClass:[NTESContactUtilCell class]]) {
        [(NTESContactUtilCell *)cell refreshWithContactItem:contactItem];
    }else{
        [(NIMContactDataCell *)cell refreshUser:contactItem];
    }
    return cell;
}

#pragma mark - Private
- (void)enterPersonalCard:(NSString *)userId
{
    NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
    [self.presentingViewController.navigationController pushViewController:vc animated:YES];
}

@end
