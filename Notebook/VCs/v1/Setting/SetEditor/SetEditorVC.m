//
//  SetEditorVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SetEditorVC.h"
#import "SettingNavBar.h"
#import "SettingItemCell.h"
#import "SettingCellHeader.h"
#import "RowHeightCell.h"
#import "SettingSave.h"

@interface SetEditorVC ()
@property (copy, nonatomic) NSArray *datasource ;
@property (copy, nonatomic) NSArray *ulistDatasource ;

@end

@implementation SetEditorVC

+ (instancetype)getMe {
    SetEditorVC *vc = [SetEditorVC getCtrllerFromStory:@"Main" controllerIdentifier:@"SetEditorVC"] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.datasource = [PlistUtil arrayWithPlist:@"EditorSetData"] ;
    self.ulistDatasource = @[@"-",@"*",@"+"] ;
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    self.fd_prefersNavigationBarHidden = YES ;
    self.fd_interactivePopDisabled = YES ;
    [SettingNavBar addInController:self] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    [SettingItemCell xt_registerNibFromTable:self.table] ;
    [RowHeightCell xt_registerNibFromTable:self.table] ;
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
    return self.datasource.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource[section] count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingSave *sSave = [SettingSave fetch] ;
    NSInteger sec = indexPath.section ;
    NSInteger row = indexPath.row ;
    NSDictionary *dic = self.datasource[sec][row] ;
    
    if (sec == 1) {
        RowHeightCell *cell = [RowHeightCell xt_fetchFromTable:tableView] ;
        cell.slider.value = sSave.editor_lightHeightRate ;
        cell.lbSlideVal.text = XT_STR_FORMAT(@"%.1f",sSave.editor_lightHeightRate) ;
        return cell ;
    }
    
    SettingItemCell *cell = [SettingItemCell xt_fetchFromTable:tableView] ;
    cell.delegate = self ;
    [cell xt_configure:dic] ;

    NSString *title = dic[@"t"] ;
    if ([title containsString:@"自动补全括号"]) {
        [cell.swt setOn:sSave.editor_autoAddBracket animated:NO] ;
    }
    else if ([title isEqualToString:@"无序列表符号"]) {
        cell.lbDesc.text = sSave.editor_md_ulistSymbol ;
        cell.sepLineMode = SettingCellSeperateLine_Mode_Top ;
    }
    else if ([title isEqualToString:@"宽松的列表"]) {
        [cell.swt setOn:sSave.editor_isLooseList animated:NO] ;
        cell.sepLineMode = SettingCellSeperateLine_Mode_Bottom ;
    }
    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sec = indexPath.section ;
    if (sec == 1) return [RowHeightCell xt_cellHeight] ;
    return [SettingItemCell xt_cellHeight] ;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SettingCellHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SettingCellHeader"] ;
    if (!header) header = [[SettingCellHeader alloc] initWithReuseIdentifier:@"SettingCellHeader"] ;
    switch (section) {
        case 0: header.lbTitle.text = @"编辑器设置" ; break ;
        case 1: header.lbTitle.text = @"" ; break ;
        case 2: header.lbTitle.text = @"markdown" ; break ;
        default: break ;
    }
    return header ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 30 ;
    }
    return 37 ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    
    NSDictionary *dic = self.datasource[section][row] ;
    NSString *title = dic[@"t"] ;
    SettingSave *sSave = [SettingSave fetch] ;
    if ([title containsString:@"无序列表符号"]) {
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:@"选择无序列表符号" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:self.ulistDatasource fromWithView:self.view CallBackBlock:^(NSInteger btnIndex) {
            if (!btnIndex) return ;
            
            NSLog(@"%@", self.ulistDatasource[btnIndex - 1]) ;
            sSave.editor_md_ulistSymbol = self.ulistDatasource[btnIndex - 1] ;
            [sSave save] ;
            
            [tableView reloadData] ;
        }] ;
    }
}

#pragma mark - SettingItemCellDelegate <NSObject>

- (void)switchStateChanged:(JTMaterialSwitchState)currentState dic:(NSDictionary *)dic {
    SettingSave *sSave = [SettingSave fetch] ;
    NSString *title = dic[@"t"] ;
    if ([title isEqualToString:@"自动补全括号"]) {
        sSave.editor_autoAddBracket = (currentState == JTMaterialSwitchStateOn) ;
    }
    else if ([title isEqualToString:@"宽松的列表"]) {
        sSave.editor_isLooseList = (currentState == JTMaterialSwitchStateOn) ;
    }
    [sSave save] ;
}

@end

