 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"
#import <XTlib/XTPhotoAlbum.h>
#import "AppDelegate.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "ArticleInfoVC.h"
#import "OutputPreviewVC.h"
#import "OutputPreviewsNailView.h"
#import "UIViewController+CWLateralSlide.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import <WebKit/WebKit.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "GlobalDisplaySt.h"
#import "HomePadVC.h"
#import "NHSlidingController.h"
#import "HomeVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OctRequestUtil.h"
#import "OctShareCopyLinkView.h"


@interface MarkdownVC () <WKScriptMessageHandler>
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;
@property (weak, nonatomic) IBOutlet UIButton *btShare;


@property (strong, nonatomic) XTCameraHandler   *handler;
@property (strong, nonatomic) ArticleInfoVC     *infoVC ;

@property (strong, nonatomic) Note              *aNote ;
@property (copy, nonatomic)   NSString          *myBookID ;
@property (strong, nonatomic) WKWebView         *webView ;
@property (strong, nonatomic) OutputPreviewsNailView *nail ;
@property (nonatomic)         float             snapDuration ;

@property (strong, nonatomic) UIActivityIndicatorView *activityView ;
@property (nonatomic)         BOOL              isInTrash ;
@end

@implementation MarkdownVC

#pragma mark - Life

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarddownVC"] ;
    vc.aNote = note ;
    vc.delegate = (id <MarkdownVCDelegate>)ctrller ;
    vc.myBookID = bookID ;
    if (!note && !bookID) vc.canBeEdited = NO ;
    else vc.canBeEdited = YES ;
    [vc.editor.toolBar reset] ;
    [ctrller.navigationController pushViewController:vc animated:YES] ;
    return vc ;
}

- (void)setupWithNote:(Note *)note
               bookID:(NSString *)bookID
          fromCtrller:(UIViewController *)ctrller {
    
    self.aNote = note ;
    self.delegate = (id <MarkdownVCDelegate>)ctrller ;
    self.myBookID = bookID ;
    self.emptyView.hidden = note != nil ;
    self.editor.aNote = note ?: [Note new] ;
    self.editor.left = -[GlobalDisplaySt sharedInstance].containerSize.width / 4. + 28 ;
    self.canBeEdited = [GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 ;
    [self.editor.toolBar reset] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.view.xt_maskToBounds = YES ;
    if (self.aNote) self.editor.aNote = self.aNote ;
    else {
        self.editor.aNote = [[Note alloc] initWithBookID:nil content:nil title:nil] ;
        WEAK_SELF
        [self.editor nativeCallJSWithFunc:@"setMarkdown" json:@"" completion:^(NSString *val, NSError *error){
            weakSelf.editor.webViewHasSetMarkdown = YES ;
        }] ;
        [self.editor openKeyboard] ;
    }
    
//    self.fd_interactivePopDisabled = YES ;
    
    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.6] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon && [GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) return ;
        
        // Update Your Note
        [self updateMyNote] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil] takeUntil:self.rac_willDeallocSignal] throttle:3] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        // Sync your note
        if (!self.aNote) return ;
        
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
         [self.editor changeTheme] ;
         
         for (UIView *sub in self.topBar.subviews) {
             if ([sub isKindOfClass:UIVisualEffectView.class]) {
                 [sub removeFromSuperview] ;
             }
         }
         [self.topBar oct_addBlurBg] ;
         [self.topBar setNeedsLayout] ;
         [self.topBar layoutIfNeeded] ;
     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Make_Big_Photo object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSString *json = x.object ;
        [self snapShotFullScreen:json] ;
    }] ;        
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNoteSlidingSizeChanging object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
        
        [self.editor setSideFlex] ;
        
        self.editor.bottom = self.view.bottom ;
        self.editor.top = APP_STATUSBAR_HEIGHT ;
        self.editor.width = [GlobalDisplaySt sharedInstance].containerSize.width ;
        self.editor.height = [GlobalDisplaySt sharedInstance].containerSize.height - APP_STATUSBAR_HEIGHT ;
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1) {
            self.editor.left = 0. ;
        }
        else {
            self.editor.left = -[GlobalDisplaySt sharedInstance].containerSize.width / 4. + 28 ;
        }
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_book_Changed object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
        
        NoteBooks *book = x.object ;
        
        if (![self.aNote.noteBookId isEqualToString:book.icRecordName]) {
            [self.editor nativeCallJSWithFunc:@"setMarkdown" json:@"" completion:^(NSString *val, NSError *error) {}];
            [self.editor leavePage] ;
            self.editor.aNote = nil ;
            self.emptyView.hidden = NO ;
        }
        
        self.emptyView.area.hidden = (book.vType == Notebook_Type_trash) ;
        self.isInTrash = (book.vType == Notebook_Type_trash) ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Send_Share_Html object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        [MBProgressHUD hideHUDForView:self.view animated:YES] ;
        
        @weakify(self)
        NSString *html = x.object ;
        [OctRequestUtil getShareHtmlLink:html complete:^(NSString * _Nonnull urlString) {
            @strongify(self)
            if (urlString) {
                NSLog(@"getShareHtmlLink : %@", urlString) ;
                [self.editor hideKeyboard] ;
                
//                @weakify(self)
                [OctShareCopyLinkView showOnView:self.view
                                            link:urlString
                                        complete:^(BOOL ok) {
//                    @strongify(self)
                    if (ok) {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = urlString ;
                        [SVProgressHUD showSuccessWithStatus:@"分享链接已经复制到剪贴板"] ;
                    }
                }] ;
            }
        }] ;
    }] ;
    
    [[[[RACObserve([GlobalDisplaySt sharedInstance], gdst_level_for_horizon)
       deliverOnMainThread]
       takeUntil:self.rac_willDeallocSignal]
      throttle:.2]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self)
         int num = [x intValue] ;
         if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
         
         self.canBeEdited = num == -1 ;
         [UIView animateWithDuration:.1 animations:^{
             if (num == -1) self.btBack.transform = CGAffineTransformScale(self.btBack.transform, -1, 1) ;
             else self.btBack.transform = CGAffineTransformIdentity ;
         }] ;
         
         if (self.aNote == nil || self.editor.aNote == nil || self.editor.aNote.content.length < 1) {
             if (num == -1) {
                 self.emptyView.hidden = YES ;
                 self.myBookID = self.delegate.currentBookID ;
                 self.editor.webViewHasSetMarkdown = YES ;
                 [self.editor openKeyboard] ;
             }
             else {
                 self.emptyView.hidden = NO ;
             }
         }
         
         if (num != -1) {
             [self.editor hideKeyboard] ;
         }
        
     }] ;
    
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
        id target = self.navigationController.interactivePopGestureRecognizer.delegate ;
        // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:pan];
        // 禁止使用系统自带的滑动手势
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    else { // ipad大
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] ;
        [self.view addGestureRecognizer:tap] ;
    }
}

- (void)tapped:(UIGestureRecognizer *)recog {
    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1) return ;
    if (self.isInTrash) return ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return YES ;
    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon != 1) return YES ;
    
    return [self.oct_panDelegate oct_gestureRecognizerShouldBegin:gestureRecognizer] ;
}

// 一句话总结就是此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应。
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



- (void)panned:(UIPanGestureRecognizer *)recognizer {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
    
    CGPoint offset = [recognizer translationInView:self.view] ;
    // NSLog(@"offset : %@", NSStringFromCGPoint(offset)) ;
    CGFloat velocity = [recognizer velocityInView:self.view].x ;
    
    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 && velocity < 0) return ;
    if (self.isInTrash && velocity < 0 && [GlobalDisplaySt sharedInstance].gdst_level_for_horizon == 0) return ; // 垃圾桶 不能新建        
    
    switch ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon) {
        // 里层
        case -1: [self.pad_panDelegate pad_panned:recognizer] ; break;
        case 0: { // 中层
            if (velocity > 0) { //
//                NSLog(@"👉") ;
                [self.oct_panDelegate oct_panned:recognizer] ; // 外层
            }
            else { //
//                NSLog(@"👈") ;
                [self.pad_panDelegate pad_panned:recognizer] ; // 里层
            }
        } break;
        // 外层
        case  1: [self.oct_panDelegate oct_panned:recognizer] ; break;
        
        default: break;
    }
}

- (void)handleNavigationTransition:(id)ges {} // 调用系统自带滑动手势的target的action方法







- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    [self leaveOut] ;
}

#define XT_HIDE_HUD        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
[MBProgressHUD hideHUDForView:self.view.window animated:YES] ;\
});\

#define XT_HIDE_HUD_RETURN  {dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
[MBProgressHUD hideHUDForView:self.view.window animated:YES] ;\
});\
return;}

- (void)leaveOut {
    if ([GlobalDisplaySt sharedInstance].isInNewBookVC) {
        return ;
    }
    
    if (!self.editor.webViewHasSetMarkdown) {
        [self.editor leavePage] ;
        XT_HIDE_HUD
        return ;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES] ;
    
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
    if (markdown && markdown.length) {
        Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:markdown title:title] ;
        self.aNote = newNote ;
        [Note createNewNote:self.aNote] ;
        [self.delegate addNoteComplete:self.aNote] ;
    }
    XT_HIDE_HUD
}

- (void)updateMyNote {
    if (!self.aNote) XT_HIDE_HUD_RETURN
    if (!self.editor.webViewHasSetMarkdown) XT_HIDE_HUD_RETURN
    if (self.editor.articleAreTheSame) XT_HIDE_HUD_RETURN
    if (![self.editor.aNote.icRecordName isEqualToString:self.aNote.icRecordName]) XT_HIDE_HUD_RETURN
    
    NSString *markdown = self.editor.aNote.content ;
    NSString *title = [Note getTitleWithContent:markdown] ;
    
    self.aNote.content = markdown ;
    self.aNote.title = title ;
    [Note updateMyNote:self.aNote] ;
    [self.delegate editNoteComplete:self.aNote] ;
    XT_HIDE_HUD
}




#pragma mark - UI

- (void)prepareUI {
    [self editor] ;
    
    self.editor.xt_theme_backgroundColor = k_md_bgColor ;
    self.editor.themeStr = [MDThemeConfiguration sharedInstance].currentThemeKey ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heightForBar.constant = APP_STATUSBAR_HEIGHT + 55 ;        
    }) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.btBack.xt_theme_imageColor = k_md_iconColor ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    self.btShare.xt_theme_imageColor = k_md_iconColor ;
    [self.btBack xt_enlargeButtonsTouchArea] ;
    [self.btMore xt_enlargeButtonsTouchArea] ;
    [self.btShare xt_enlargeButtonsTouchArea] ;
    
    self.navArea.backgroundColor = nil ;
    self.topBar.backgroundColor = nil ;

    [self.topBar setNeedsDisplay] ;
    [self.topBar layoutIfNeeded] ;
    [self.topBar oct_addBlurBg] ;
    
    if (IS_IPAD) {
        [self.btBack setImage:[UIImage imageNamed:@"nav_back_reverse_item@2x"] forState:0] ;
    }
}

- (IBAction)backAction:(id)sender {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon) {
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_PullBack object:nil] ;
            [self leaveOut] ;
        }
        return ;
    }
    
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(id)sender {
    if (!self.canBeEdited) return ;
    
    [self.editor nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(NSString *val, NSError *error) {
    }] ;

    [self infoVC] ;
    self.infoVC.aNote = self.aNote ;
    self.infoVC.webInfo = self.editor.webInfo ;
    WEAK_SELF
    self.infoVC.blkDelete = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES] ;
    } ;
    
    // 导出预览
    self.infoVC.blkOutput = ^{
        [weakSelf.editor hideKeyboard] ;
        [weakSelf.editor nativeCallJSWithFunc:@"getPureHtml" json:nil completion:^(NSString *val, NSError *error) {}] ;
    } ;
    
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:[ArticleInfoVC movingDistance] maskAlpha:0.4 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil] ;
    [self cw_showDrawerViewController:self.infoVC animationType:0 configuration:conf] ;
}

- (void)snapShotFullScreen:(NSString *)htmlString {
    [self dismissViewControllerAnimated:YES completion:nil] ;
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] ;
    self.activityView.center = self.view.window.center ;
    [self.view.window addSubview:self.activityView] ;
    self.activityView.color = [UIColor darkGrayColor] ;
    [self.activityView startAnimating] ;
    
    self.editor.hidden = YES ;
    
    NSMutableString *tmpStr = [htmlString mutableCopy] ;
    htmlString = [tmpStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""] ;
    
    NSString *path = XT_DOCUMENTS_PATH_TRAIL_(@"pic.html") ;
    [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
    NSURL *url = [NSURL fileURLWithPath:path] ;
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new] ;
    [config.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"] ;
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config] ;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    _webView.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
    _webView.opaque = NO ;
    [self.view addSubview:_webView] ;
    [_webView.configuration.userContentController addScriptMessageHandler:(id <WKScriptMessageHandler>)self name:@"WebViewBridge"] ;
    [_webView loadFileURL:url allowingReadAccessToURL:url] ;
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.snapDuration = .2 + (float)textHeight / (float)APP_HEIGHT * .2 ;
            self.webView.height = textHeight ;
            
            self.view.frame = CGRectMake(0, 0, APP_WIDTH , textHeight) ;
            [self.view setNeedsLayout] ;
            [self.view layoutIfNeeded] ;
            CGSize size = self.view.frame.size ;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.snapDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UIGraphicsBeginImageContextWithOptions(size, true,  [UIScreen mainScreen].scale) ;
                [self.view.layer renderInContext:UIGraphicsGetCurrentContext()] ;
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
                UIGraphicsEndImageContext() ;
                
                [self.webView removeFromSuperview] ;
                self.webView = nil ;
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image] ;
                [self.view addSubview:imageView] ;
                imageView.height = textHeight ;
                
                self.nail = [OutputPreviewsNailView makeANail] ;
                self.nail.top = textHeight ;
                [self.view addSubview:self.nail] ;
                self.view.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + self.nail.height) ;
                image = [UIImage getImageFromView:self.view] ;
                
                
                [self.nail removeFromSuperview] ;
                self.nail = nil ;
                [imageView removeFromSuperview] ;
                imageView = nil ;
                
                self.editor.hidden = NO ;
                [self.activityView stopAnimating] ;
                
                if (!image) return ;
                [OutputPreviewVC showFromCtrller:self imageOutput:image] ;
            }) ;
        }) ;
    }
}

- (IBAction)shareAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    [self.editor getShareHtml] ;
}



#pragma mark - prop

- (void)setCanBeEdited:(BOOL)canBeEdited {
    _canBeEdited = canBeEdited ;
    
    if (canBeEdited) {
        [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"setEditable" json:[@(TRUE) stringValue] completion:^(NSString *val, NSError *error) {
        }] ;
    }
    else {
        [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"setEditable" json:[@(FALSE) stringValue] completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [OctWebEditor sharedInstance] ;
        _editor.bottom = self.view.bottom ;
        _editor.left = self.view.left ;
        _editor.top = APP_STATUSBAR_HEIGHT ;
        _editor.width = self.view.width ;
        _editor.height = self.view.height - APP_STATUSBAR_HEIGHT ;
        
        [self.view insertSubview:_editor atIndex:0] ;
    }
    return _editor ;
}

- (ArticleInfoVC *)infoVC{
    if(!_infoVC){
        _infoVC = ({
            ArticleInfoVC *infoVC = [ArticleInfoVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
            infoVC;
       });
    }
    return _infoVC;
}

- (UIViewController *)fromCtrller {
    return self ;
}

- (HomeEmptyPHView *)emptyView {
    if (!_emptyView) {
        _emptyView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _emptyView.bottom = self.view.bottom ;
        _emptyView.left = self.view.left ;
        _emptyView.top = self.topBar.bottom ;
        _emptyView.width = [GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView ;
        _emptyView.lbPh.textAlignment = NSTextAlignmentCenter ;
        [self.view addSubview:_emptyView] ;
        _emptyView.hidden = YES ;
        
        [_emptyView.area bk_whenTapped:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_new_Note_In_Pad object:nil] ;
        }] ;
    }
    return _emptyView ;
}

@end
