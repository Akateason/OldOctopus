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
    self.table.xt_theme_backgroundColor = k_md_bgColor ;
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [LDSepLineCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    
    self.xt_theme_backgroundColor = k_md_drawerColor ;
    self.lbHead.xt_theme_backgroundColor = k_md_themeColor ;
    self.lbHead.textColor = [UIColor whiteColor] ;
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
}

- (void)setupUser {
    XTIcloudUser *user = [XTIcloudUser userInCacheSyncGet] ;
    self.lbHead.text = [user.givenName substringToIndex:1] ;
    self.lbName.text = user.name ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4 ;
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
        return [LDSepLineCell xt_fetchFromTable:tableView] ;
    }
    else if (indexPath.row == 3) {
        [cell xt_configure:self.addBook indexPath:indexPath] ;
    }
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) return 13. ;
    return [LDNotebookCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.ld_delegate LDHeadDidSelectedOneBook:self.bookRecent] ;
    }
    else if (indexPath.row == 1) {
        [self.ld_delegate LDHeadDidSelectedOneBook:self.bookStaging] ;
    }
    else if (indexPath.row == 3) {
        [self.ld_delegate LDHeadDidSelectedOneBook:self.addBook] ;
    }
    
//    [tableView reloadData] ;
}

@end
