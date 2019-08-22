//
//  OcHomeVC+UIPart.m
//  Notebook
//
//  Created by teason23 on 2019/8/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC+UIPart.h"
#import "UIView+OctupusExtension.h"
#import "SettingVC.h"
#import "SearchVC.h"
#import "MarkdownVC.h"


@implementation OcHomeVC (UIPart)

- (void)xt_prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    // collections
    [OcBookCell      xt_registerNibFromCollection:self.bookCollectionView] ;
    [OcContainerCell xt_registerNibFromCollection:self.mainCollectionView] ;
    
    self.bookCollectionView.delegate    = (id<UICollectionViewDelegate>)self ;
    self.bookCollectionView.dataSource  = (id<UICollectionViewDataSource>)self ;
    self.mainCollectionView.delegate    = (id<UICollectionViewDelegate>)self ;
    self.mainCollectionView.dataSource  = (id<UICollectionViewDataSource>)self ;
    self.mainCollectionView.pagingEnabled = YES ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - 134.) ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    layout.minimumLineSpacing = 0 ;
    self.mainCollectionView.collectionViewLayout = layout ;
    
    // 加号
    [self btAdd] ;
    self.btAdd.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    self.btAdd.layer.shadowOffset = CGSizeMake(0, 7.5) ;
    self.btAdd.layer.shadowOpacity = 15 ;
    self.btAdd.layer.shadowRadius = 5 ;
    
    // 按钮
    WEAK_SELF
    [self.btUser bk_addEventHandler:^(id sender) {
        
        [weakSelf.btUser oct_buttonClickAnimationComplete:^{
            
            [SettingVC getMeFromCtrller:weakSelf fromView:weakSelf.btUser] ;
        }] ;
        
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    
    [self.btSearch bk_addEventHandler:^(id sender) {
        
        [weakSelf.btSearch oct_buttonClickAnimationComplete:^{
            
            [SearchVC showSearchVCFrom:weakSelf inTrash:NO] ;
        }] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btAdd bk_whenTapped:^{
        
        [weakSelf.btAdd oct_buttonClickAnimationComplete:^{
            
            [weakSelf addBtOnClick:weakSelf.btAdd] ;
        }] ;
    }] ;
}

- (void)addBtOnClick:(id)sender {
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"🖋 新建笔记",@"📒 新建笔记本"] fromWithView:sender CallBackBlock:^(NSInteger btnIndex) {
        
        @strongify(self)
        if (btnIndex == 1) { // new note
            [MarkdownVC newWithNote:nil bookID:self.currentBook.icRecordName fromCtrller:self] ;
        }
        else if (btnIndex == 2) { // new book
            self.nBookVC =
            [NewBookVC showMeFromCtrller:self
                                fromView:sender
                                 changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                                     // create new book
                                     NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
                                     [NoteBooks createNewBook:aBook] ;
                                     self.nBookVC = nil ;
                                     
                                     // save curent book in UD .
                                     XT_USERDEFAULT_SET_VAL(aBook.icRecordName, kUDCached_lastBook_RecID) ;
                                     [self getAllBooks] ;
                                     self.currentBook = aBook ;
                                                                          
                                 } cancel:^{
                                     self.nBookVC = nil ;
                                 }] ;
        }
    }] ;
}



#pragma mark - MarkdownVCDelegate <NSObject>

- (void)addNoteComplete:(Note *)aNote {
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.mainCollectionView.xt_currentIndexPath] ;
    [cell.contentCollection xt_loadNewInfoInBackGround:NO] ;
}

- (void)editNoteComplete:(Note *)aNote {
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.mainCollectionView.xt_currentIndexPath] ;
    [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
}

- (NSString *)currentBookID {
    return self.currentBook.icRecordName ;
}

- (int)currentBookType {
    return self.currentBook.vType ;
}

@end
