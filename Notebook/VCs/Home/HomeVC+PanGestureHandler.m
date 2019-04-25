//
//  HomeVC+PanGestureHandler.m
//  Notebook
//
//  Created by teason23 on 2019/4/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC+PanGestureHandler.h"
#import "NoteBooks.h"
#import "Note.h"
#import "NoteCell.h"
#import "MoveNoteToBookVC.h"
#import "LeftDrawerVC.h"


@implementation HomeVC (PanGestureHandler)

- (NSArray *)setupPanList {
    
    if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:@"彻底删除" handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
            Note *aNote = ((NoteCell *)cell).xt_model ;
            // Delete Note
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要彻底删除此文章吗?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
                
                if (btnIndex == 1) {
                    
                    [Note deleteThisNoteFromICloud:aNote complete:^(bool success) {
                        [self.table xt_loadNewInfoInBackGround:YES] ;
                    }] ;
                    
                }
            }] ;
            return YES ;
        }] ;
        item1.xt_theme_backgroundColor = k_md_themeColor ;
        item1.tintColor = [UIColor whiteColor] ;
        item1.width = 60 ;
        item1.image = [UIImage imageNamed:@"home_del_note"] ;
        
        
        SWCellButtonItem *item2 = [SWCellButtonItem itemWithTitle:@"恢复笔记" handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
            __block Note *aNote = ((NoteCell *)cell).xt_model ;
            // Move Note
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要恢复此文章吗?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
                
                if (btnIndex == 1) {
                    aNote.isDeleted = NO ;
                    [aNote xt_update] ;
                    [Note updateMyNote:aNote] ;
                    
                    NoteBooks *book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",aNote.noteBookId)] ;
                    book.isDeleted = NO ;
                    [book xt_update] ;
                    [NoteBooks updateMyBook:book] ;
                    
                    [self.table xt_loadNewInfoInBackGround:YES] ;
                }
            }] ;
            
            return YES ;
        }] ;
        item2.backgroundColor = [UIColor darkGrayColor] ;
        item2.tintColor = [UIColor whiteColor] ;
        item2.width = 60 ;
        item2.image = [UIImage imageNamed:@"home_huifu"] ;
        
        return @[item1,item2] ;
        
    }
    else {
         SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:@"删除" handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
            Note *aNote = ((NoteCell *)cell).xt_model ;
            // Delete Note
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要将此文章放入垃圾桶?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
                if (btnIndex == 1) {
                    aNote.isDeleted = YES ;
                    [Note updateMyNote:aNote] ;
                    [self.table xt_loadNewInfoInBackGround:YES] ;
                }
            }] ;
            return YES ;
        }] ;
        item1.xt_theme_backgroundColor = k_md_themeColor ;
        item1.tintColor = [UIColor whiteColor] ;
        item1.width = 60 ;
        item1.image = [UIImage imageNamed:@"home_del_note"] ;
        
        
        SWCellButtonItem *item2 = [SWCellButtonItem itemWithTitle:@"移动" handler:^BOOL(SWCellButtonItem *item, SWRevealTableViewCell *cell) {
            __block Note *aNote = ((NoteCell *)cell).xt_model ;
            // Move Note
            @weakify(self)
            [MoveNoteToBookVC showFromCtrller:self
                                   moveToBook:^(NoteBooks * _Nonnull book) {
                                       @strongify(self)
                                       aNote.noteBookId = book.icRecordName ;
                                       [Note updateMyNote:aNote] ;
                                       [self.leftVC refreshHomeWithBook:book] ;
                                   }] ;
            return YES ;
        }] ;
        item2.backgroundColor = [UIColor darkGrayColor] ;
        item2.tintColor = [UIColor whiteColor] ;
        item2.width = 60 ;
        item2.image = [UIImage imageNamed:@"home_move_note"] ;
        
        return @[item1,item2] ;
    }
}


@end
