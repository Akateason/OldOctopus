//
//  IAPSubscriptionVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPSubscriptionVC.h"
#import "SettingNavBar.h"
#import "IAPSepLineCell.h"
#import "IAPIntroductionCell.h"
#import "IAPPayCell.h"
#import "IAPInfoBottomCell.h"


@interface IAPSubscriptionVC ()
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubTitle;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation IAPSubscriptionVC

+ (instancetype)getMe {
    return [IAPSubscriptionVC getCtrllerFromStory:@"Main" controllerIdentifier:@"IAPSubscriptionVC"] ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    self.fd_prefersNavigationBarHidden = YES ;
    [SettingNavBar addInController:self] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbSubTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    
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
    [IAPPayCell xt_registerNibFromTable:self.table] ;
    [IAPInfoBottomCell xt_registerNibFromTable:self.table] ;
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
        IAPIntroductionCell *cell = [IAPIntroductionCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    else if (row == 2) {
        IAPPayCell *cell = [IAPPayCell xt_fetchFromTable:tableView] ;
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
        return [IAPIntroductionCell xt_cellHeight] ; 
    }
    else if (row == 2) {
        return [IAPPayCell xt_cellHeight] ;
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
