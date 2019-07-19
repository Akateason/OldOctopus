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
#import <XTlib/XTlib.h>


@implementation HomeVC (PanGestureHandler)

- (NSArray *)setupPanList:(MGSwipeButton *)cell {
    
    UIColor *itemBgColor = UIColorRGBA(24, 18, 17, .03) ;
    
    if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        MGSwipeButton *bt1 = [MGSwipeButton buttonWithTitle:@"彻底删除" icon:[UIImage imageNamed:@"home_del_note"] backgroundColor:itemBgColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            
            Note *aNote = ((NoteCell *)cell).xt_model ;
            // Delete Note
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要彻底删除此文章吗?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
                
                if (btnIndex == 1) {
                    cell.userInteractionEnabled = NO ;
                    [Note deleteThisNoteFromICloud:aNote complete:^(bool success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.userInteractionEnabled = YES ;
                            [self.table xt_loadNewInfoInBackGround:YES] ;
                        }) ;
                    }] ;
                }
            }] ;
            
            return YES ;
        }] ;
        bt1.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
        bt1.xt_theme_imageColor = k_md_iconColor ;
        [bt1 xt_setImagePosition:(XTBtImagePositionTop) spacing:6] ;
        
        MGSwipeButton *bt2 = [MGSwipeButton buttonWithTitle:@"恢复" icon:[UIImage imageNamed:@"home_huifu"] backgroundColor:itemBgColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            
            Note *aNote = ((NoteCell *)cell).xt_model ;

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
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.table xt_loadNewInfoInBackGround:YES] ;
                    }) ;
                }
            }] ;

           return YES ;
        }] ;
        bt2.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
        bt2.xt_theme_imageColor = k_md_iconColor ;
        [bt2 xt_setImagePosition:(XTBtImagePositionTop) spacing:6] ;
        
        return @[bt1,bt2] ;
        
    }
    else {
        MGSwipeButton *bt1 = [MGSwipeButton buttonWithTitle:@"删除" icon:[UIImage imageNamed:@"home_del_note"] backgroundColor:itemBgColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            
            Note *aNote = ((NoteCell *)cell).xt_model ;
            // Delete Note
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要将此文章放入垃圾桶?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
                if (btnIndex == 1) {
                    aNote.isDeleted = YES ;
                    [Note updateMyNote:aNote] ;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.table xt_loadNewInfoInBackGround:YES] ;
                    }) ;
                }
            }] ;
            return YES ;
        }] ;

        bt1.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
        bt1.xt_theme_imageColor = k_md_iconColor ;
        [bt1 xt_setImagePosition:(XTBtImagePositionTop) spacing:6] ;
        bt1.buttonWidth = 70 ;

        
        MGSwipeButton *bt2 = [MGSwipeButton buttonWithTitle:@"移动" icon:[UIImage imageNamed:@"home_move_note"] backgroundColor:itemBgColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            
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
        bt2.xt_theme_imageColor = k_md_iconColor ;
        bt2.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
        [bt2 xt_setImagePosition:(XTBtImagePositionTop) spacing:6] ;
        bt2.buttonWidth = 70 ;
        
        
        __block Note *aNote = ((NoteCell *)cell).xt_model ;
        MGSwipeButton *bt3 = [MGSwipeButton buttonWithTitle:aNote.isTop ? @"取消置顶" : @"置顶" icon:[UIImage imageNamed:@"home_top_note"] backgroundColor:itemBgColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            // 置顶
            aNote.isTop = !aNote.isTop ;
            aNote.modifyDateOnServer = [[NSDate date] xt_getTick] ;
            
            NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
            [tmplist replaceObjectAtIndex:cell.xt_indexPath.row withObject:aNote] ;
            
            [self dealTopNoteLists:tmplist] ;
            [self.table reloadData] ;
            if (aNote.isTop) { // 移动动画
                [self.table moveRowAtIndexPath:cell.xt_indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] ;
            }
            
            [Note updateMyNote:aNote] ;
            
            return YES ;
        }] ;
        
        bt3.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
        bt3.xt_theme_imageColor = k_md_iconColor ;
        [bt3 xt_setImagePosition:(XTBtImagePositionTop) spacing:6] ;
        bt3.buttonWidth = aNote.isTop ? 100 : 70 ;
        
        return @[bt1,bt2,bt3] ;
    }
}


@end
