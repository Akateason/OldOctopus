//
//  HomeVC+Util.m
//  Notebook
//
//  Created by teason23 on 2019/5/15.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC+Util.h"
#import "LeftDrawerVC.h"
#import "MarkdownVC.h"
#import "NewBookVC.h"

@implementation HomeVC (Util)

- (void)addBtOnClick:(id)sender {
    if (![XTIcloudUser hasLogin]) {
        [XTIcloudUser alertUserToLoginICloud] ;
        return ;
    }
    
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"🖋 新建笔记",@"📒 新建笔记本"] fromWithView:sender CallBackBlock:^(NSInteger btnIndex) {
        @strongify(self)
        if (btnIndex == 1) {
            [MarkdownVC newWithNote:nil bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
        }
        else if (btnIndex == 2) {
            self.nBookVC =
            [NewBookVC showMeFromCtrller:self changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                // create new book
                NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
                [NoteBooks createNewBook:aBook] ;
                self.nBookVC = nil ;
                
                [self.leftVC render] ;
                [self.leftVC refreshHomeWithBook:aBook] ;
            } cancel:^{
                self.nBookVC = nil ;
            }] ;
        }
    }] ;
    

}

- (void)moreBtOnClick:(id)sender {
    if (![XTIcloudUser hasLogin]) {
        [XTIcloudUser alertUserToLoginICloud] ;
        return ;
    }
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除笔记本" otherButtonTitles:@[@"重命名笔记本"] fromWithView:sender CallBackBlock:^(NSInteger btnIndex) {
        @strongify(self)
        if (btnIndex == 1) { //  rename book
            __block NoteBooks *aBook = self.leftVC.currentBook ;
            @weakify(self)
            self.nBookVC =
            [NewBookVC showMeFromCtrller:self editBook:aBook changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                @strongify(self)
                aBook.name = bookName ;
                aBook.emoji = [@{@"native":emoji} yy_modelToJSONString] ;
                [NoteBooks updateMyBook:aBook] ;
                self.nBookVC = nil ;
                [self.leftVC render] ;
                [self.leftVC setCurrentBook:aBook] ;
            } cancel:^{
                @strongify(self)
                self.nBookVC = nil ;
            }] ;
        }
        else if (btnIndex == 2) { // delete book
            @weakify(self)
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"删除笔记本" message:@"删除笔记本会将此笔记本内的文章都移入回收站" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex1) {
                @strongify(self)
                if (btnIndex1 == 1) {
                    @weakify(self)
                    [NoteBooks deleteBook:self.leftVC.currentBook done:^{
                        @strongify(self)
                        self.leftVC.currentBook = nil ;
                        [self.leftVC render] ;
                    }] ;
                }
            }] ;
            
        }
    }] ;

}

@end
