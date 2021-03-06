 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"

#import "AppDelegate.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "NoteInfoVC.h"
#import "OutputPreviewVC.h"
#import "OutputPreviewsNailView.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import <WebKit/WebKit.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "GlobalDisplaySt.h"
#import "HomePadVC.h"
#import "NHSlidingController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OctRequestUtil.h"
#import "OctShareCopyLinkView.h"
#import "OctMBPHud.h"
#import "HomeTrashEmptyPHView.h"
#import "SearchVC.h"
#import "GuidingICloud.h"
#import "IAPSubscriptionVC.h"
#import "MDEKeyboardPhotoView.h"
#import "AppstoreCommentUtil.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import "MarkdownVC+Keycommand.h"
#import "MarkdownVC+Notification.h"


@interface MarkdownVC () <WKScriptMessageHandler>
@property (copy, nonatomic)   NSString          *myBookID ;
@property (strong, nonatomic) WKWebView         *webView ; // 导出
@property (strong, nonatomic) UIView            *snapBgView ;
@property (strong, nonatomic) OutputPreviewsNailView *nail ;
@property (nonatomic)         float             snapDuration ;

@property (strong, nonatomic) RACSubject        *outputPhotoSubject ;

@end

@implementation MarkdownVC

- (void)test {
    UIDocumentPickerExtensionViewController *docVC = [[UIDocumentPickerExtensionViewController alloc] init] ;
    [self presentViewController:docVC animated:YES completion:nil];

}

+ (CGFloat)getEditorLeftIpad {
    return - [OctWebEditor sharedInstance].sideWid + k_side_margin ;
}

#pragma mark - Life
// 当 bookID == nil 时, 笔记在暂存区创建
//
+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller {
    
    return  [self newWithNote:note
                       bookID:bookID
          isCreateNewFromIpad:NO
                  fromCtrller:ctrller] ;
}

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
        isCreateNewFromIpad:(BOOL)newFromIpad
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarkdownVC"] ;
    vc.aNote = note ;
    vc.isNewFromIpad = newFromIpad ;
    
    if (note) {
        vc.editor.aNote = note ;
    }
    else {
        vc.editor.aNote = [[Note alloc] initWithBookID:nil content:nil title:nil] ;
    }
    vc.canBeEdited = YES ;
    
    vc.delegate = (id <MarkdownVCDelegate>)ctrller ;
    vc.myBookID = bookID ;
    [vc.editor.toolBar reset] ;
    [ctrller.navigationController pushViewController:vc animated:YES] ;
    
    return vc ;
}

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID
          fromCtrller:(UIViewController *)ctrller {
    
    self.aNote = note ;
    if (ctrller != nil) self.delegate = (id <MarkdownVCDelegate>)ctrller ;
    self.myBookID = bookID ;
    self.emptyView.hidden = note != nil ;
    self.isCreateEmptyNote = (note == nil) ? 1 : 0 ;
    self.editor.aNote = note ?: [Note new] ;
    self.editor.left = [self.class getEditorLeftIpad] ;
    self.canBeEdited = YES ; // [GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 ;
    [self.editor.toolBar reset] ;
}

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID {
    [self setupWithNote:note bookID:bookID fromCtrller:nil] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.xt_maskToBounds = YES ;
    [self.editor toolBar] ;
    [[OctWebEditor sharedInstance] setSideFlex] ;
    [[OctWebEditor sharedInstance] setupSettings] ;
    [OctWebEditor sharedInstance].note_clientID = self.aNote.pkid;
    
    SettingSave *sSave = [SettingSave fetch] ;
    float duration = [sSave currentAnimationDuration] ;
    
    [self setupNotifications] ;
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kEditor_Scrolling_NavShow object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [UIView animateWithDuration:duration animations:^{
            self.heightForBar.constant = 55 + APP_STATUSBAR_HEIGHT ;
            self.heightForNavBar.constant = 55 ;
        }] ;
    }] ;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kEditor_Scrolling_NavHidden object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [UIView animateWithDuration:duration animations:^{
            self.heightForNavBar.constant = self.heightForBar.constant = 0 ;
        }] ;
    }] ;
    
    [[[self.subjectIpadKeyboardCommand throttle:.4] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self callbackKeycommand:x] ;
    }] ;
    
    [[[self.outputPhotoSubject throttle:.4] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (!self.isSnapshoting) return ;
        
        float textHeight = [x floatValue] ;
        textHeight -= (55 + APP_SAFEAREA_STATUSBAR_FLEX) ;
        if ( textHeight < APP_HEIGHT) textHeight += 100. ;

        self.snapDuration = .4 + (float)textHeight / (float)APP_HEIGHT * .35 ;
        
        CGSize snapSize = CGSizeMake(APP_WIDTH, textHeight) ;
        self.snapBgView.frame = CGRectMake(0, 0, APP_WIDTH , textHeight) ;
        [self.snapBgView setNeedsLayout] ;
        [self.snapBgView layoutIfNeeded] ;
        self.webView.height = textHeight ;
        [self.webView setNeedsLayout] ;
        [self.webView layoutIfNeeded] ;
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.snapDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            UIGraphicsBeginImageContextWithOptions(snapSize, true,  [UIScreen mainScreen].scale) ;
            [self.snapBgView.layer renderInContext:UIGraphicsGetCurrentContext()] ;
            __block UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
            UIGraphicsEndImageContext() ;

            dispatch_async(dispatch_get_main_queue(), ^{
                self.webView.hidden = YES ;
                [self.webView removeFromSuperview] ;
                self->_webView = nil ;

                UIImageView *imageView = [[UIImageView alloc] initWithImage:image] ;
                [self.snapBgView addSubview:imageView] ;
                imageView.height = textHeight ;

                self.nail = [OutputPreviewsNailView makeANail] ;
                self.nail.top = textHeight ;
                self.nail.backgroundColor = UIColorHex(@"FAFAFA") ;
                [self.snapBgView addSubview:self.nail] ;
                self.snapBgView.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + self.nail.height) ;
                image = [UIImage getImageFromView:self.snapBgView] ;

                [self.nail removeFromSuperview] ;
                self.nail = nil ;
                [imageView removeFromSuperview] ;
                imageView = nil ;
                [self.snapBgView removeFromSuperview] ;
                self.snapBgView = nil ;

                self.editor.hidden = NO ;
                self.navArea.hidden = NO ;
                
                [[OctMBPHud sharedInstance] hide] ;
                
                if (!image) return ;
                [OutputPreviewVC showFromCtrller:self imageOutput:image] ;
                
            }) ;
        }) ;
    }] ;
    
    
    id target = self.navigationController.interactivePopGestureRecognizer.delegate ;
    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:pan];
    // 禁止使用系统自带的滑动手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [self.oct_panDelegate oct_gestureRecognizerShouldBegin:gestureRecognizer] ;
}

// 此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleNavigationTransition:(id)ges {} // 调用系统自带滑动手势的target的action方法

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    
    if (self.isNewFromIpad && !self.isSnapshoting) {
        self.editor.left = [self.class getEditorLeftIpad] ;
        // self.canBeEdited = NO ; 在webview第一次初始化之后,设置才有用.
    }
    
    if (self.isSnapshoting) {
        self.isSnapshoting = NO ;
        self.editor.left = 0 ;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"clicked navigationbar back button 编辑器页面返回 ！");
        [self leaveOut] ; //
    }
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated] ;
//
//    [self test] ;
//}

#define XT_HIDE_HUD        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
[[OctMBPHud sharedInstance] hide] ;\
});\

#define XT_HIDE_HUD_RETURN  {dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
[[OctMBPHud sharedInstance] hide] ;\
});\
return;}

- (void)leaveOut {
    [self.editor.toolBar reset] ;
    [self.editor.toolBar removeFromSuperview] ;
    self.editor.toolBar = nil ;
    
    if ([GlobalDisplaySt sharedInstance].isInNewBookVC) {
        return ;
    }
    
    if (!self.editor.webViewHasSetMarkdown) {
        [self.editor leavePage] ;
        XT_HIDE_HUD
        return ;
    }
    
    [[OctMBPHud sharedInstance] show] ;
    
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        self.editor.aNote.content = markdown ;
        
        if (self.editor.articleAreTheSame) {
            [self.editor leavePage] ;
            XT_HIDE_HUD
            return ;
        }
        
        if (self.aNote) {
            // Update Your Note
            [self updateMyNote] ;
        }
        else {
            // Create New Note
            [self createNewNote] ;
        }
        
        [self.editor leavePage] ;
    }] ;
    

}

#pragma mark - Func

- (void)createNewNote {
    NSString *markdown = self.editor.aNote.content ;
    NSString *title = [Note getTitleWithContent:markdown] ;
    if (markdown && markdown.length && ![markdown isEqualToString:@"\n"]) {
        Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:markdown title:title] ;
        self.aNote = newNote ;
        [Note createNewNote:self.aNote] ;

        [OctWebEditor sharedInstance].note_clientID = self.aNote.pkid;
        
        XT_USERDEFAULT_SET_VAL(newNote.icRecordName, kUDCached_lastNote_RecID) ;
        [self.delegate addNoteComplete:self.aNote] ;
        [self.editor setValue:newNote forKey:@"_aNote"] ;
    }
    XT_HIDE_HUD
}

- (void)updateMyNote {
    if (!self.aNote) {
        // new note
        [self createNewNote] ;
        return ;
    }
    if (!self.editor.webViewHasSetMarkdown) XT_HIDE_HUD_RETURN
    if (self.editor.articleAreTheSame) XT_HIDE_HUD_RETURN
    if (![self.editor.aNote.icRecordName isEqualToString:self.aNote.icRecordName]) XT_HIDE_HUD_RETURN
    
        
    NSString *markdown = self.editor.aNote.content ;
    NSString *title = [Note getTitleWithContent:markdown] ;
    
    if (![markdown length] || [markdown isEqualToString:@"\n"]) XT_HIDE_HUD_RETURN
    
    self.aNote.content = markdown ;
    self.aNote.title = title ;
    [Note updateMyNote:self.aNote] ;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Note_Edited object:self.aNote];
    
    XT_HIDE_HUD
}

- (void)clearArticleInIpad {
    self.emptyView.hidden = NO ;
    
    NSDictionary *dic = @{@"markdown":@"", @"isRenderCursor": @0 } ;
    [self.editor nativeCallJSWithFunc:@"setMarkdown" json:dic completion:^(NSString *val, NSError *error) {}] ;
    [self.editor leavePage] ;
    self.editor.aNote = nil ;
}

#pragma mark - UI

- (void)prepareUI {
    [self editor] ;
    
    self.editor.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heightForBar.constant = APP_STATUSBAR_HEIGHT + 55 ;        
    }) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.btBack.xt_theme_imageColor = k_md_iconColor ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
//    self.btShare.xt_theme_imageColor = k_md_iconColor ;
    [self.btBack xt_enlargeButtonsTouchArea] ;
    [self.btMore xt_enlargeButtonsTouchArea] ;
//    [self.btShare xt_enlargeButtonsTouchArea] ;
    
    self.navArea.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .8) ;
    self.topBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .8) ;            
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(UIButton *)sender {
    if (!self.canBeEdited) return ;
    
    [sender oct_buttonClickAnimationComplete:^{
        [self openMoreInfoView] ;
    }] ;
}

- (void)openMoreInfoView {
    [self.editor hideKeyboard] ;
    
    WEAK_SELF
    [NoteInfoVC showFromCtrller:self
                           note:self.aNote
                       webModel:self.editor.webInfo
                 outputCallback:^(NoteInfoVC * _Nonnull infoVC) {
                        
        [weakSelf.editor hideKeyboard] ;
        [infoVC dismissViewControllerAnimated:YES completion:nil] ;
        
        [weakSelf.editor nativeCallJSWithFunc:@"getPureHtml" json:nil completion:^(NSString *val, NSError *error) {}] ;
        
    } removeCallBack:^(NoteInfoVC * _Nonnull infoVC) {
        
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要将此文章放入垃圾桶?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
            if (btnIndex == 1) {
                self.aNote.isDeleted = YES ;
                [Note updateMyNote:self.aNote] ;
                
                [weakSelf.navigationController popViewControllerAnimated:YES] ;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
            }
        }] ;

    }] ;
}

- (void)snapShotFullScreen:(NSString *)htmlString {
    [self dismissViewControllerAnimated:YES completion:nil] ;
    
    [[OctMBPHud sharedInstance] show] ;
    
    self.editor.hidden = YES ;
    self.navArea.hidden = YES ;
    
    NSMutableString *tmpStr = [htmlString mutableCopy] ;
    htmlString = [tmpStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""] ;
    
    NSString *path = XT_LIBRARY_PATH_TRAIL_(@"pic.html") ;
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
    NSURL *url = [NSURL fileURLWithPath:path] ;
    
    if (!self.snapBgView.superview) {
        self.snapBgView.frame = self.view.bounds ;
        [self.view addSubview:self.snapBgView] ;
    }
    
    if (!self.webView.superview) {
        [self.snapBgView addSubview:self.webView] ;
    }
    
    if (!self.isSnapshoting) {
        self.isSnapshoting = YES ;
        
        [self.webView loadFileURL:url allowingReadAccessToURL:url] ;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *body = message.body ;       // 就是 JS 调用 Native 时，传过来的 value
    NSLog(@"%@", body) ;
    NSDictionary *ret = [WebModel convertjsonStringToJsonObj:body] ;
    NSString *func = ret[@"method"] ;
    NSDictionary *jsonDic = ret[@"params"] ;
    NSLog(@"WebViewBridge func : %@\njson : %@",func,jsonDic) ;
    
    if ([func isEqualToString:@"snapshotHeight"]) {
        float textHeight = [ret[@"params"] floatValue] ;
        [self.outputPhotoSubject sendNext:@(textHeight)] ;
    }
}

//- (IBAction)shareAction:(UIButton *)sender {
//    [sender oct_buttonClickAnimationComplete:^{
//        [self.editor hideKeyboard] ;
//        [[OctMBPHud sharedInstance] show] ;
//        [self.editor getShareHtml] ;
//    }] ;
//}

#pragma mark - prop

- (void)setCanBeEdited:(BOOL)canBeEdited {
    _canBeEdited = canBeEdited ;
    
    [[OctWebEditor sharedInstance] setEditable:canBeEdited] ;
}

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [OctWebEditor sharedInstance] ;
        _editor.bottom = self.view.bottom ;
        _editor.top = APP_STATUSBAR_HEIGHT ;
        _editor.width = [GlobalDisplaySt sharedInstance].containerSize.width ;
        _editor.height = [GlobalDisplaySt sharedInstance].containerSize.height - APP_STATUSBAR_HEIGHT ;
                
        [self.view insertSubview:_editor atIndex:0] ;
    }
    return _editor ;
}

- (UIViewController *)fromCtrller {
    return self ;
}

- (HomeEmptyPHView *)emptyView {
    if (!_emptyView) {
        _emptyView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _emptyView.height = APP_HEIGHT - self.topBar.bottom ;
        _emptyView.left = self.view.left ;
        _emptyView.top = self.topBar.bottom ;
        _emptyView.width = [GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView ;
        _emptyView.lbPh.textAlignment = NSTextAlignmentCenter ;
        [self.view addSubview:_emptyView] ;
        _emptyView.hidden = YES ;
    }
    _emptyView.height = APP_HEIGHT - self.topBar.bottom ;
    _emptyView.top = self.topBar.bottom ;
    _emptyView.width = [GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView ;
    return _emptyView ;
}

- (XTCameraHandler *)cameraHandler {
    if (!_cameraHandler) {
        _cameraHandler = [[XTCameraHandler alloc] init] ;
    }
    return _cameraHandler ;
}

- (RACSubject *)outputPhotoSubject{
    if(!_outputPhotoSubject){
        _outputPhotoSubject = ({
            RACSubject * object = [[RACSubject alloc] init];
            object;
       });
    }
    return _outputPhotoSubject;
}

- (WKWebView *)webView{
    if(!_webView){
        _webView = ({
            WKWebViewConfiguration *config = [WKWebViewConfiguration new] ;
            [config.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"] ;
            
            WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config] ;
            webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
            webView.backgroundColor = [UIColor whiteColor] ;
            webView.opaque = NO ;
            webView.hidden = NO ;
            [webView.configuration.userContentController addScriptMessageHandler:(id <WKScriptMessageHandler>)self name:@"WebViewBridge"] ;
            webView ;
       }) ;
    }
    return _webView;
}

- (UIView *)snapBgView{
    if(!_snapBgView){
        _snapBgView = ({
            UIView *object = [[UIView alloc] init] ;
            object.frame = self.view.bounds ;
            object.backgroundColor = [UIColor whiteColor] ;
            object;
       });
    }
    return _snapBgView;
}

- (RACSubject *)subjectIpadKeyboardCommand {
    if (!_subjectIpadKeyboardCommand) {
        _subjectIpadKeyboardCommand = [RACSubject new] ;
    }
    return _subjectIpadKeyboardCommand ;
}

@end
