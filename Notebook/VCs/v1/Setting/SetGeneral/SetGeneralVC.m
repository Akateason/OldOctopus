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
    self.view.xt_theme_backgroundColor = k_md_backColor ;
    self.fd_prefersNavigationBarHidden = YES ;
    [SettingNavBar addInController:self] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    [SettingItemCell xt_registerNibFromTable:self.table] ;
    [self.table registerClass:SettingCellHeader.class forHeaderFooterViewReuseIdentifier:@"SettingCellHeader"] ;
    self.table.dataSource   = self ;
    self.table.delegate     = self ;
    self.table.xt_theme_backgroundColor = k_md_midDrawerPadColor ;
    self.table.estimatedRowHeight           = 0;
    self.table.estimatedSectionHeaderHeight = 0;
    self.table.estimatedSectionFooterHeight = 0;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *tableTopLine = [UIView new] ;
    tableTopLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    [self.view addSubview:tableTopLine] ;
    [tableTopLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view) ;
        make.top.equalTo(self.table.mas_top) ;
        make.height.equalTo(@.5) ;
    }] ;
}


#pragma mark - UITableViewDataSource<NSObject>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    SettingItemCell *cell = [SettingItemCell xt_fetchFromTable:tableView] ;
    cell.delegate = self ;
    NSDictionary *dic = self.datasource[row] ;
    [cell xt_configure:dic] ;
    
    SettingSave *sSave = [SettingSave fetch] ;
    
    NSString *title = dic[@"t"] ;
    if ([title containsString:@"笔记本"]) {
        cell.lbDesc.text = !sSave.sort_isBookUpdateTime ? @"修改时间" : @"创建时间" ;
        cell.sepLineMode = SettingCellSeperateLine_Mode_Middel ;
    }
    else if ([title isEqualToString:@"笔记"]) {
        cell.lbDesc.text = !sSave.sort_isNoteUpdateTime ? @"修改时间" : @"创建时间" ;
        cell.sepLineMode = SettingCellSeperateLine_Mode_Bottom ;
    }
    else if ([title isEqualToString:@"最新优先"]) {
        [cell.swt setOn:sSave.sort_isNewestFirst animated:NO] ;
        cell.sepLineMode = SettingCellSeperateLine_Mode_Top ;
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
    return 37. ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    NSDictionary *dic = self.datasource[row] ;
    NSString *title = dic[@"t"] ;
    SettingItemCell *cell = [tableView cellForRowAtIndexPath:indexPath] ;
    
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"修改时间",@"创建时间"] fromWithView:cell CallBackBlock:^(NSInteger btnIndex) {
    
        SettingSave *sSave = [SettingSave fetch] ;
        if ([title containsString:@"笔记本"]) {
            if (btnIndex == 1) {
                sSave.sort_isBookUpdateTime = FALSE ;
            }
            else if (btnIndex == 2) {
                sSave.sort_isBookUpdateTime = TRUE ;
            }
        }
        else if ([title isEqualToString:@"笔记"]) {
            if (btnIndex == 1) {
                sSave.sort_isNoteUpdateTime = FALSE ;
            }
            else if (btnIndex == 2) {
                sSave.sort_isNoteUpdateTime = TRUE ;
            }
        }
        [sSave save] ;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)] ;
    }] ;
    
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
