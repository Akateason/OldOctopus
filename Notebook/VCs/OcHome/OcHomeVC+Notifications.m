//
//  OcHomeVC+Notifications.m
//  Notebook
//
//  Created by teason23 on 2019/8/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC+Notifications.h"
#import "MarkdownVC.h"

@implementation OcHomeVC (Notifications)

- (void)xt_setupNotifications {
    
    // BOOK RELATIVE NOTIFICATES
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         
         [self.btUser setImage:[UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] forState:0] ;
         
         self.segmentBooks.titleColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
         self.segmentBooks.titleSelectedColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) ;
         
         [self refreshAll] ;
     }] ;
            
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_iap_purchased_done object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self getAllBooks] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil]
        takeUntil:self.rac_willDeallocSignal]
       deliverOnMainThread]
      throttle:1.]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         NSLog(@"go sync list") ;
         
         [self getAllBooksIfNeeded] ;
     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_User_Login_Success object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        [self getAllBooks] ;
        
        [self.btUser setImage:[UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] forState:0] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationImportFileIn object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
        NSURL *url = x.object ;
        NSString *path = url.path ;
        NSString *md = [[NSString alloc] initWithContentsOfFile:path encoding:(NSUTF8StringEncoding) error:nil] ;
        NSString *title = [Note getTitleWithContent:md] ;
        //1. 判断是否是documents目录下的已经存在的文章 ?
        NSString *documentsPath = [XTArchive getDocumentsPath] ;
        if ([path containsString:documentsPath]) {
        // 是否在docments目录下
            NSString *uniqueKey = [[path componentsSeparatedByString:documentsPath] lastObject] ;
            uniqueKey = [uniqueKey substringFromIndex:1] ;
            uniqueKey = [uniqueKey substringToIndex:uniqueKey.length - 3] ;
            NSLog(@"%@",uniqueKey) ;
            Note *bNote = [Note xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",uniqueKey)] ;
            if (bNote) {
                //3. 如果文章已存在, 则打开已存在的文章进行编辑
                // 已存在
                [MarkdownVC newWithNote:bNote bookID:bNote.noteBookId fromCtrller:self] ;

                return ;
            }
            else {
                // 不存在, 则新建
            }
        }
        else {
            // 不在docments目录下, 则新建
        }
        
        //4. 则新建文章
         Note *aNote = [[Note alloc] initWithBookID:self.currentBook.icRecordName content:md title:title] ;
         [Note createNewNote:aNote] ;
         
         [self getAllBooks] ;
         [MarkdownVC newWithNote:aNote bookID:self.currentBook.icRecordName fromCtrller:self] ;
    

     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Default_Note_And_Book_Updated object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSLog(@"kNote_Default_Note_And_Book_Updated") ;
        [self getAllBooksIfNeeded] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_SizeClass_Changed object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        NSIndexPath *idp = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
        [self.mainCollectionView reloadData] ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mainCollectionView scrollToItemAtIndexPath:idp atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO] ;
            

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:idp] ;
                [cell.contentCollection reloadData] ;
            });
        }) ;
    }] ;
}


@end
