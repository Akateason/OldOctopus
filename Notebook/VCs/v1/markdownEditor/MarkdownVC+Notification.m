//
//  MarkdownVC+Notification.m
//  Notebook
//
//  Created by teason23 on 2019/12/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC+Notification.h"
#import "MarkdownVC.h"
#import "OctRequestUtil.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import "OctShareCopyLinkView.h"

@implementation MarkdownVC (Notification)

- (void)setupNotifications {
    
    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.6] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Update Your Note
        [self updateMyNote] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_User_Open_Camera object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)

        @weakify(self)
        [self.cameraHandler openCameraFromController:self takePhoto:^(XTImageItem *imageResult) {
            if (!imageResult) return;
            
            @strongify(self)
            [self.editor sendImageLocalPathWithImageItem:imageResult] ;
        }] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil] takeUntil:self.rac_willDeallocSignal] throttle:3] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Sync your note
        if (!self.aNote || self.aNote.content.length <= 1 ) return ;
        
        NSLog(@"Sync your note") ;
        
        __block Note *noteFromIcloud = [Note xt_findFirstWhere: XT_STR_FORMAT(@"icRecordName == '%@'",self.aNote.icRecordName)] ;
        if ([noteFromIcloud.content isEqualToString:self.aNote.content]) return ; // 如果内容一样,不处理
        
        self.aNote = noteFromIcloud ;
        self.editor.aNote = noteFromIcloud ;
        [self.editor renderNote] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         self.editor.themeStr = [MDThemeConfiguration sharedInstance].currentThemeKey ;
     }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Make_Big_Photo object:nil] throttle:.5] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        NSString *json = x.object ;
        [self snapShotFullScreen:json] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_SizeClass_Changed object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[OctWebEditor currentOctWebEditor] setSideFlex] ;
            
            if (!self.editor.window) return ;
            
            self.editor.bottom = self.view.bottom ;
            self.editor.top = APP_STATUSBAR_HEIGHT ;
            self.editor.width = [GlobalDisplaySt sharedInstance].containerSize.width ;
            self.editor.height = [GlobalDisplaySt sharedInstance].containerSize.height - APP_STATUSBAR_HEIGHT ;
        });
                
    }] ;
    
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_SearchVC_On_Window object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // 搜索开启时, 右边和垃圾桶一样处理 .
        bool isOn = [x.object boolValue] ;
        self.emptyView.isTrash = isOn ;
        self.isInTrash = isOn ;
        self.btBack.hidden = isOn ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Send_Share_Html object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        self.isInShare = YES ;
        [[OctMBPHud sharedInstance] hide] ;
        
        @weakify(self)
        NSString *html = x.object ;
        [OctRequestUtil getShareHtmlLink:html complete:^(NSString * _Nonnull urlString) {
            @strongify(self)
            if (urlString) {
                NSLog(@"getShareHtmlLink : %@", urlString) ;
                [self.editor hideKeyboard] ;
                
                @weakify(self)
                [OctShareCopyLinkView showOnView:self.view
                                            link:urlString
                                        complete:^(BOOL ok) {
                    @strongify(self)
                    self.isInShare = NO ;
                    if (ok) {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = urlString ;
                        [SVProgressHUD showSuccessWithStatus:@"分享链接已经复制到剪贴板"] ;
                    }
                }] ;
            }
        }] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Delete_Note_In_Pad object:nil] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self clearArticleInIpad] ;
    }] ;

}



@end
