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
         
         self.segmentBooks.titleColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
         self.segmentBooks.titleSelectedColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) ;
         
         [self refreshAll] ;
     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        @weakify(self)
        [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
            if (user != nil) {
                @strongify(self)
                [self getAllBooks] ;
            }
        }] ;
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
         // if (self.isOnDeleting) return ;
         
         [self getAllBooks] ;
     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationImportFileIn object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         NSString *path = x.object ;
         NSString *md = [[NSString alloc] initWithContentsOfFile:path encoding:(NSUTF8StringEncoding) error:nil] ;
         NSString *title = [Note getTitleWithContent:md] ;
         Note *aNote = [[Note alloc] initWithBookID:self.currentBook.icRecordName content:md title:title] ;
         [Note createNewNote:aNote] ;
         
         [self getAllBooks] ;
         [MarkdownVC newWithNote:aNote bookID:self.currentBook.icRecordName fromCtrller:self] ;
     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        @weakify(self)
        [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
            if (user != nil) {
                @strongify(self)
                [self getAllBooks] ;
            }
        }] ;
    }] ;
}


@end
