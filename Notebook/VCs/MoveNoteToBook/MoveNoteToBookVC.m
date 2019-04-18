//
//  MoveNoteToBookVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MoveNoteToBookVC.h"
#import "LDNotebookCell.h"

typedef void(^BlkMoveBook)(NoteBooks *book);

@interface MoveNoteToBookVC () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btClose;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *imgRightCornerPaint;

@property (copy, nonatomic) NSArray *booklist ;
@property (copy, nonatomic) BlkMoveBook blkMove ;
@end

@implementation MoveNoteToBookVC

+ (instancetype)showFromCtrller:(UIViewController *)ctrller
                     moveToBook:(void(^)(NoteBooks *book))blkMove {
    
    MoveNoteToBookVC *vc = [MoveNoteToBookVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MoveNoteToBookVC"] ;
    ctrller.definesPresentationContext = YES;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext ;
    [ctrller presentViewController:vc animated:YES completion:^{
    }] ;
    vc.blkMove = blkMove ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.backgroundColor = nil ; //
    [self addBlurBg] ;
    
    
    self.booklist = [NoteBooks xt_findWhere:@"isOnSelect == 0 AND isDeleted == 0"] ;
    self.table.separatorStyle = 0 ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.backgroundColor = nil ;
    
    [LDNotebookCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    WEAK_SELF
    [self.btClose bk_addEventHandler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{}] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
}

- (void)prepareUI {
    self.lbTitle.xt_theme_textColor = k_md_textColor ;
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booklist.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDNotebookCell *cell = [LDNotebookCell xt_fetchFromTable:tableView indexPath:indexPath] ;
    [cell xt_configure:self.booklist[indexPath.row] indexPath:indexPath] ;
    cell.backgroundColor = nil ;

    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LDNotebookCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block NoteBooks *aBook ;
    [self.booklist enumerateObjectsUsingBlock:^(NoteBooks *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isOnSelect = (indexPath.row == idx) ;
        if (indexPath.row == idx) aBook = obj ;
    }] ;
    [self.table reloadData] ;
    
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"移动笔记" message:XT_STR_FORMAT(@"移动笔记到《%@》?",aBook.name) cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            self.blkMove(aBook) ;
            [self dismissViewControllerAnimated:YES completion:^{}] ;
        }
    }] ;
}

@end
