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
#import "Note.h"
#import "NoteBooks.h"
#import "UIView+OctupusExtension.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "OctWebEditor.h"
#import "HiddenUtil.h"
#import "OctGuidingVC.h"

@interface SettingVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UILabel *lbAccountTitle;
@property (weak, nonatomic) IBOutlet UIImageView *img_arrow_account;
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
    
    if ([GlobalDisplaySt sharedInstance].vType >= SC_Home_mode_iPad_Horizon_6_collumn) {
        settignVC.preferredContentSize = CGSizeMake(400, 700) ;
        navVC.modalPresentationStyle = UIModalPresentationPopover ;
        UIPopoverPresentationController *popVC = navVC.popoverPresentationController ;
        popVC.sourceView = fromView ; // contentController.view ;
        popVC.sourceRect = CGRectMake(30, -80, 0, 0) ;  // CGRectMake(50, -20, 0, 0) ;
        popVC.permittedArrowDirections = UIPopoverArrowDirectionLeft ;
        
        popVC.xt_theme_backgroundColor = k_md_bgColor ;
    }
    else {
        navVC.modalPresentationStyle = UIModalPresentationFullScreen ;
    }
                
    [contentController presentViewController:navVC animated:YES completion:^{}] ;
    return navVC ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    
    
    NSArray *data = [PlistUtil arrayWithPlist:@"SettingItems" bundle:[NSBundle bundleForClass:self.class]] ;
    self.datasource = data ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.userHead.image = [UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] ;
        [self.table reloadData] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_User_Login_Success object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.userHead.image = [UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] ;
        NSString *givenName = [XTIcloudUser displayUserName] ;
        self.lbName.text = givenName ;
        self.img_arrow_account.hidden = YES ;
    }] ;
    
    // 清数据 暗开关
    [self.view xt_whenTouches:2 tapped:7 handler:^{
        [HiddenUtil showAlert] ;
    }] ;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated] ;
    
    [[OctWebEditor sharedInstance] setupSettings] ;
    [self.table reloadData] ;
}

- (void)prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    self.btClose.xt_theme_imageColor = k_md_iconColor ;
    [self.btClose xt_enlargeButtonsTouchArea] ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbAccountTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    if ([XTIcloudUser hasLogin]) {
        self.userHead.image = [UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] ;
        self.img_arrow_account.hidden = YES ;
    }
    else {
        self.userHead.image = [UIImage imageNamed:@"icon_user_not_login"] ;
        self.img_arrow_account.hidden = NO ;
    }
    
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    [SettingCell xt_registerNibFromTable:self.table] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_theme_backgroundColor = k_md_backColor ;
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
    [self.btClose xt_whenTapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    NSString *givenName = [XTIcloudUser displayUserName] ;    
    self.lbName.text = givenName.length > 0 ? givenName : @"已登录" ;
    
    self.lbVersionNum = ({
        UILabel *lb = [UILabel new] ;
        lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
        NSString *versionNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ;
        NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ;
        lb.text = XT_STR_FORMAT(@"v %@ (%@) %@ 小章鱼©",versionNum,buildNum, (k_Is_Internal_Testing) ? @"内测" : @"") ;
        lb.font = [UIFont systemFontOfSize:12.] ;
        lb.textAlignment = NSTextAlignmentCenter ;

        lb ;
    }) ;
    self.lbVersionNum.userInteractionEnabled = YES ;
    [self.lbVersionNum xt_whenTapped:^{
        OctGuidingVC *vc = [OctGuidingVC getMeForce] ;
        vc.modalPresentationStyle = UIModalPresentationFullScreen ;
        [weakSelf.navigationController presentViewController:vc animated:YES completion:nil] ;
    }] ;
    
    self.lbVersionNum.height = 100 ;
    self.lbVersionNum.width = self.view.bounds.size.width ;
    self.table.tableFooterView = self.lbVersionNum ;

    
    
    self.userHead.userInteractionEnabled = self.lbName.userInteractionEnabled = YES ;
    
    [self.userHead xt_whenTapped:^{
        if (![XTIcloudUser hasLogin]) [[XTCloudHandler sharedInstance] alertCallUserToIcloud:weakSelf] ;
    }] ;
    
    [self.lbName xt_whenTapped:^{
        if (![XTIcloudUser hasLogin]) [[XTCloudHandler sharedInstance] alertCallUserToIcloud:weakSelf] ;
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
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    SettingCell *cell = [SettingCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.datasource[section][row] indexPath:indexPath] ;
    
    if (section == 0) {
        cell.sepLineMode = SettingCellSeperateLine_Mode_ALL_FULL ;
    }
    else if (section == 1) {
        if (row == 0) cell.sepLineMode = SettingCellSeperateLine_Mode_Top ;
        else if (row == 3) cell.sepLineMode = SettingCellSeperateLine_Mode_Bottom ;
        else cell.sepLineMode = SettingCellSeperateLine_Mode_Middel ;
    }
    else if (section == 2) {
        cell.sepLineMode = SettingCellSeperateLine_Mode_ALL_FULL ;
    }
    else if (section == 3) {
        if (row == 0) cell.sepLineMode = SettingCellSeperateLine_Mode_Top ;
        else if (row == 1) cell.sepLineMode = SettingCellSeperateLine_Mode_Bottom ;
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
