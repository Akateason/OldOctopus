//
//  IAPSuccessSubscriptionVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPSuccessSubscriptionVC.h"
#import "SettingNavBar.h"
#import "IAPSepLineCell.h"
#import "IAPIntroductionCell.h"
#import "IAPInfoBottomCell.h"
#import "IapPaySuccessCell.h"
#import "AppDelegate.h"



@interface IAPSuccessSubscriptionVC ()

@end

@implementation IAPSuccessSubscriptionVC

+ (instancetype)getMe {
    return [IAPSuccessSubscriptionVC getCtrllerFromStory:@"Main" controllerIdentifier:@"IAPSuccessSubscriptionVC"] ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_iap_purchased_done object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    self.fd_prefersNavigationBarHidden = YES ;
    [SettingNavBar addInController:self] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbDesc.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    
    self.topLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    
    self.table.xt_theme_backgroundColor = k_md_midDrawerPadColor ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0;
    self.table.estimatedSectionHeaderHeight = 0;
    self.table.estimatedSectionFooterHeight = 0;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [IAPSepLineCell xt_registerNibFromTable:self.table] ;
    [IAPIntroductionCell xt_registerNibFromTable:self.table] ;
    [IAPInfoBottomCell xt_registerNibFromTable:self.table] ;
    [IapPaySuccessCell xt_registerNibFromTable:self.table] ;
}


#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    if (row == 0) {
        IAPSepLineCell *cell = [IAPSepLineCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    else if (row == 1) {
        IapPaySuccessCell *cell = [IapPaySuccessCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    else if (row == 2) {
        IAPIntroductionCell *cell = [IAPIntroductionCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    else if (row == 3) {
        IAPInfoBottomCell *cell = [IAPInfoBottomCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    
    return nil ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    if (row == 0) {
        return [IAPSepLineCell xt_cellHeight] ;
    }
    else if (row == 1) {
        return [IapPaySuccessCell xt_cellHeight] ;
    }
    else if (row == 2) {
        return [IAPIntroductionCell xt_cellHeight] ;
    }
    else if (row == 3) {
        return [IAPInfoBottomCell xt_cellHeight] ;
    }
    return 0 ;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
