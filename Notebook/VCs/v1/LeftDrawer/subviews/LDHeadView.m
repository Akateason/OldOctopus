//
//  LDHeadView.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LDHeadView.h"
#import "XTCloudHandler.h"
#import "MDThemeConfiguration.h"
#import <BlocksKit+UIKit.h>
#import "LDNotebookCell.h"
#import "Note.h"
#import "NoteBooks.h"
#import "LDSepLineCell.h"
#import "HomeVC.h"
#import "IapUtil.h"
#import "AppDelegate.h"

@interface LDHeadView ()

@end


@implementation LDHeadView

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.table.scrollEnabled = NO ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.estimatedRowHeight           = 0 ;
    self.table.estimatedSectionHeaderHeight = 0 ;
    self.table.estimatedSectionFooterHeight = 0 ;
    self.table.xt_theme_backgroundColor = k_md_drawerColor ;
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [LDSepLineCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    
    self.xt_theme_backgroundColor = k_md_drawerColor ;
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    
    ([MDThemeConfiguration sharedInstance].isDarkMode) ? [self.btTheme setImage:[UIImage imageNamed:@"ld_theme_day"] forState:0] : [self.btTheme setImage:[UIImage imageNamed:@"ld_theme_night"] forState:0] ;
    
    self.btTheme.xt_theme_imageColor = k_md_iconColor ;
    [self.btTheme xt_enlargeButtonsTouchArea] ;
    self.btTheme.hidden = ![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist] ;
    
    @weakify(self)
    [self.btTheme bk_whenTapped:^{
        @strongify(self)
        
        UIView *circle = [UIView new] ;
        circle.backgroundColor = ([MDThemeConfiguration sharedInstance].isDarkMode) ? UIColorHex(@"f9f6f6") : UIColorHex(@"2b2f33") ;
        CGPoint point = [self convertPoint:self.btTheme.center toView:self.window] ;
        float side = MAX(APP_HEIGHT, APP_WIDTH) ;
        circle.frame = CGRectMake(0, 0, side * 2 + 100, side * 2 + 100) ;
        circle.center = point ;
        circle.xt_completeRound = YES ;
        [self.window addSubview:circle] ;
        
        circle.layer.transform = CATransform3DMakeScale(0, 0, 1) ;
        
        [UIView animateWithDuration:.25 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            circle.layer.transform = CATransform3DIdentity ;
            circle.alpha = .8 ;
        } completion:^(BOOL finished) {
            
            [[MDThemeConfiguration sharedInstance] setThemeDayOrNight:(![MDThemeConfiguration sharedInstance].isDarkMode)] ;
            (![MDThemeConfiguration sharedInstance].isDarkMode) ? [self.btTheme setImage:[UIImage imageNamed:@"ld_theme_day"] forState:0] : [self.btTheme setImage:[UIImage imageNamed:@"ld_theme_night"] forState:0] ;
                        
            [circle removeFromSuperview] ;
        }] ;
    }] ;
                
    self.userHead.userInteractionEnabled = self.lbName.userInteractionEnabled = YES ;
    [self.userHead bk_whenTapped:^{
        @strongify(self)
        if (![XTIcloudUser hasLogin]) {
            [[XTCloudHandler sharedInstance] alertCallUserToIcloud:self.xt_viewController] ;
        }
    }] ;
    
    [self.lbName bk_whenTapped:^{
        @strongify(self)
        if (![XTIcloudUser hasLogin]) {
            [[XTCloudHandler sharedInstance] alertCallUserToIcloud:self.xt_viewController] ;
        }
    }] ;
}

- (void)setupUser {
    NSString *givenName = [XTIcloudUser displayUserName] ;

    self.userHead.image = [UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] ;
    self.lbName.text = givenName ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView] ;
    if (indexPath.row == 0) {
        [cell xt_configure:self.bookRecent indexPath:indexPath] ;
    }
    else if (indexPath.row == 1) {
        [cell xt_configure:self.bookStaging indexPath:indexPath] ;
    }
    else if (indexPath.row == 2) {
        [cell xt_configure:self.bookTrash indexPath:indexPath] ;
    }
    else if (indexPath.row == 3) {
        return [LDSepLineCell xt_fetchFromTable:tableView] ;
    }
    else if (indexPath.row == 4) {
        [cell xt_configure:self.addBook indexPath:indexPath] ;
    }
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) return 13. ;
    return [LDNotebookCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        XT_USERDEFAULT_SET_VAL(@"", kUDCached_lastNote_RecID) ;
        [self.ld_delegate LDHeadDidSelectedOneBook:self.bookRecent] ;
    }
    else if (indexPath.row == 1) {
        XT_USERDEFAULT_SET_VAL(@"", kUDCached_lastNote_RecID) ;
        [self.ld_delegate LDHeadDidSelectedOneBook:self.bookStaging] ;
    }
    else if (indexPath.row == 2) {
        XT_USERDEFAULT_SET_VAL(@"", kUDCached_lastNote_RecID) ;
        [self.ld_delegate LDHeadDidSelectedOneBook:self.bookTrash] ;
    }
    else if (indexPath.row == 4) {
        [self.ld_delegate LDHeadDidSelectedOneBook:self.addBook] ;
    }
}

@end
