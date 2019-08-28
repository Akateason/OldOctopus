//
//  MoveNoteToBookVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MoveNoteToBookVC.h"
#import "MNTBCell.h"

typedef void(^BlkMoveBook)(NoteBooks *book);

@interface MoveNoteToBookVC () <UITableViewDataSource,UITableViewDelegate>
@property (copy, nonatomic) NSArray     *booklist ;
@property (copy, nonatomic) BlkMoveBook blkMove ;


@end

@implementation MoveNoteToBookVC

+ (instancetype)showFromCtrller:(UIViewController *)ctrller
                     moveToBook:(void(^)(NoteBooks *book))blkMove {
    
    MoveNoteToBookVC *vc = [MoveNoteToBookVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MoveNoteToBookVC"] ;
    ctrller.definesPresentationContext = YES;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext ;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
    [ctrller presentViewController:vc animated:YES completion:^{
    }] ;
    vc.blkMove = blkMove ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.booklist = [NoteBooks xt_findWhere:@"isOnSelect == 0 AND isDeleted == 0"] ;
    
    WEAK_SELF
    [self.btClose bk_addEventHandler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{}] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
}

- (void)prepareUI {
    self.view.backgroundColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .4) ;
    self.topBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconBorderColor, .03) ;
    self.lbTitle.xt_theme_textColor = k_md_textColor ;
    self.hud.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
    self.btClose.xt_theme_imageColor = k_md_iconColor ;
    
    self.topBar.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.topBar.layer.shadowOffset = CGSizeMake(0, .5) ;
    self.topBar.layer.shadowOpacity = 0 ;
    self.topBar.layer.shadowRadius = 10 ;

    
    if (IS_IPAD) {
//        self.hud.xt_cornerRadius = 13 ;
        self.width_hud.constant = 325 ;
        self.height_hud.constant = APP_HEIGHT / 3. * 2. ;
    }
    else {
        self.width_hud.constant = APP_WIDTH ;
        self.height_hud.constant = APP_HEIGHT - APP_STATUSBAR_HEIGHT * 2 ;
//        self.hud.xt_cornerRadius = 0 ;
    }
    
    
    [self.btClose xt_enlargeButtonsTouchArea] ;
    
    [MNTBCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_theme_backgroundColor = k_md_bgColor ;
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTBCell *cell = [MNTBCell xt_fetchFromTable:tableView indexPath:indexPath] ;
    [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MNTBCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block NoteBooks *aBook ;
    [self.booklist enumerateObjectsUsingBlock:^(NoteBooks *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (indexPath.row == idx) aBook = obj ;
    }] ;
    
    MNTBCell *cell = [tableView cellForRowAtIndexPath:indexPath] ;
    [cell.lbEmoji oct_buttonClickAnimationComplete:^{
        
        @weakify(self)
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"移动笔记" message:XT_STR_FORMAT(@"移动笔记到《%@》?",aBook.name) cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
            @strongify(self)
            if (btnIndex == 1) {
                self.blkMove(aBook) ;
                [self dismissViewControllerAnimated:YES completion:^{}] ;
            }
        }] ;

    }] ;
}

@end
