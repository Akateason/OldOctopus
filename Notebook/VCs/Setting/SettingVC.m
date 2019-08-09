//
//  SettingVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingVC.h"
#import "SettingCell.h"
#import <SafariServices/SafariServices.h>
#import "SetGeneralVC.h"
#import "SetThemeVC.h"
#import "SetEditorVC.h"
#import <XTBase/XTBase.h>
#import "XTCloudHandler.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "Note.h"
#import "NoteBooks.h"
#import "UIView+OctupusExtension.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "OctWebEditor.h"

@interface SettingVC ()
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UILabel *lbAccountTitle;

@property (weak, nonatomic) IBOutlet UIImageView *userHead;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) UILabel *lbVersionNum ;

@property (copy, nonatomic) NSArray *datasource ;
@end

@implementation SettingVC

+ (MDNavVC *)getMeFromCtrller:(UIViewController *)contentController fromView:(UIView *)fromView {
    SettingVC *settignVC = [SettingVC getCtrllerFromStory:@"Main" controllerIdentifier:@"SettingVC"] ;
    
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:settignVC] ;
    
    navVC.modalPresentationStyle = UIModalPresentationPopover ;
    
    UIPopoverPresentationController *popVC = navVC.popoverPresentationController ;
    popVC.sourceView = fromView ;
    popVC.sourceRect = fromView.bounds ;
    popVC.permittedArrowDirections = UIPopoverArrowDirectionAny ;
    popVC.xt_theme_backgroundColor = k_md_midDrawerPadColor ;
    
    [contentController presentViewController:navVC animated:YES completion:^{}] ;
    return navVC ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    // Do any additional setup after loading the view.
    NSArray *data = [PlistUtil arrayWithPlist:@"SettingItems" bundle:[NSBundle bundleForClass:self.class]] ;
    self.datasource = data ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        self.userHead.image = [UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] ;
    }] ;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated] ;
    
    [[OctWebEditor sharedInstance] setupSettings] ;
}

- (void)prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    self.btClose.xt_theme_imageColor = k_md_iconColor ;
    [self.btClose xt_enlargeButtonsTouchArea] ;
    
    self.view.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbAccountTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.userHead.image = [UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] ;
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    [SettingCell xt_registerNibFromTable:self.table] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
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
    
    WEAK_SELF
    [self.btClose bk_whenTapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    NSString *givenName = [XTIcloudUser displayUserName] ;    
    self.lbName.text = givenName ;
    
    self.lbVersionNum = ({
        UILabel *lb = [UILabel new] ;
        lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
        NSString *versionNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ;
        NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ;
        lb.text = XT_STR_FORMAT(@"v %@ (%@)",versionNum,buildNum) ;
        lb.font = [UIFont systemFontOfSize:12] ;
        [self.table addSubview:lb] ;
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-45) ;
            make.centerX.equalTo(self.view) ;
        }] ;
        lb ;
    }) ;
}

#pragma mark - UITableViewDataSource<NSObject>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource[section] count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    SettingCell *cell = [SettingCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.datasource[section][row] indexPath:indexPath] ;
    
    if (section == 0) {
        if (row == 0) cell.sepLineMode = SettingCellSeperateLine_Mode_Top ;
        else if (row == 3) cell.sepLineMode = SettingCellSeperateLine_Mode_Bottom ;
        else cell.sepLineMode = SettingCellSeperateLine_Mode_Middel ;
    }
    else if (section == 1) {
        cell.sepLineMode = SettingCellSeperateLine_Mode_ALL_FULL ;
    }
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SettingCell xt_cellHeight] ;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SettingHead"] ;
    if (!header) header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"SettingHead"] ;
    UIView *backgroundView = [[UIView alloc] initWithFrame:header.bounds] ;
    backgroundView.xt_theme_backgroundColor = k_md_midDrawerPadColor ;
    header.backgroundView = backgroundView ;
    return header ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30. ;
}

@end
