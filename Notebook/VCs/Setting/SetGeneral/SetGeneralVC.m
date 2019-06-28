//
//  SetGeneralVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SetGeneralVC.h"
#import "SettingNavBar.h"
#import "SettingItemCell.h"
#import "SettingCellHeader.h"
#import "SettingSave.h"

@interface SetGeneralVC ()
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (copy, nonatomic) NSArray *datasource ;
@end

@implementation SetGeneralVC

+ (instancetype)getMe {
    SetGeneralVC *vc = [SetGeneralVC getCtrllerFromStory:@"Main" controllerIdentifier:@"SetGeneralVC"] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datasource = [PlistUtil arrayWithPlist:@"GeneralData"] ;
    
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.fd_prefersNavigationBarHidden = YES ;
    [SettingNavBar addInController:self] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    [SettingItemCell xt_registerNibFromTable:self.table] ;
    [self.table registerClass:SettingCellHeader.class forHeaderFooterViewReuseIdentifier:@"SettingCellHeader"] ;
    self.table.dataSource   = self ;
    self.table.delegate     = self ;
    self.table.xt_theme_backgroundColor = k_md_bgColor ;
    self.table.estimatedRowHeight           = 0;
    self.table.estimatedSectionHeaderHeight = 0;
    self.table.estimatedSectionFooterHeight = 0;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark - UITableViewDataSource<NSObject>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row ;
    SettingItemCell *cell = [SettingItemCell xt_fetchFromTable:tableView] ;
    cell.delegate = self ;
    NSDictionary *dic = self.datasource[row] ;
    [cell xt_configure:dic] ;
    
    SettingSave *sSave = [SettingSave fetch] ;
    
    NSString *title = dic[@"t"] ;
    if ([title containsString:@"笔记本"]) {
        cell.lbDesc.text = !sSave.sort_isBookUpdateTime ? @"修改时间" : @"创建时间" ;
    }
    else if ([title isEqualToString:@"笔记"]) {
        cell.lbDesc.text = !sSave.sort_isNoteUpdateTime ? @"修改时间" : @"创建时间" ;
    }
    else if ([title isEqualToString:@"最新优先"]) {
        [cell.swt setOn:sSave.sort_isNewestFirst animated:NO] ;
    }
    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SettingItemCell xt_cellHeight] ;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SettingCellHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SettingCellHeader"] ;
    if (!header) header = [[SettingCellHeader alloc] initWithReuseIdentifier:@"SettingCellHeader"] ;
    header.lbTitle.text = @"排序" ;
    return header ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25 ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    NSDictionary *dic = self.datasource[row] ;
    NSString *title = dic[@"t"] ;
    SettingSave *sSave = [SettingSave fetch] ;
    if ([title containsString:@"笔记本"]) {
        sSave.sort_isBookUpdateTime = !sSave.sort_isBookUpdateTime  ;
    }
    else if ([title isEqualToString:@"笔记"]) {
        sSave.sort_isNoteUpdateTime = !sSave.sort_isNoteUpdateTime ;
    }
    [sSave save] ;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)] ;
    
    
    SettingItemCell *cell = [tableView cellForRowAtIndexPath:indexPath] ;
    cell.lbDesc.transform = CGAffineTransformScale(cell.lbDesc.transform, 1.1, 1.1) ;
    [UIView animateWithDuration:.35
                     animations:^{
                         cell.lbDesc.transform = CGAffineTransformIdentity ;
                     }
                     completion:nil] ;
}

#pragma mark - SettingItemCellDelegate <NSObject>

- (void)switchStateChanged:(JTMaterialSwitchState)currentState dic:(NSDictionary *)dic {
    SettingSave *sSave = [SettingSave fetch] ;
    // 最新优先
    sSave.sort_isNewestFirst = (currentState == JTMaterialSwitchStateOn) ;
    [sSave save] ;
}

@end
