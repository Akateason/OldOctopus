 //
//  MarkdownVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
// 假导航

#import "MarkdownVC.h"
#import "OctWebEditor.h"
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

@interface MarkdownVC () <WKScriptMessageHandler>
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIView *navArea;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBar;

@property (strong, nonatomic) OctWebEditor      *editor ;
@property (strong, nonatomic) XTCameraHandler   *handler;
@property (strong, nonatomic) ArticleInfoVC     *infoVC ;

@property (strong, nonatomic) Note              *aNote ;
@property (copy, nonatomic)   NSString          *myBookID ;
@property (strong, nonatomic) WKWebView         *webView ;
@property (strong, nonatomic) OutputPreviewsNailView *nail ;
@property (nonatomic)         float             snapDuration ;

@property (strong, nonatomic) UIActivityIndicatorView *activityView ;

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
    vc.canBeEdited = YES ;
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
    self.editor.aNote = note ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    if (self.aNote) self.editor.aNote = self.aNote ;
    
    
    
    
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
    
    [[[RACObserve([GlobalDisplaySt sharedInstance], gdst_level_for_horizon)
       deliverOnMainThread]
      throttle:.2]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self)
         int num = [x intValue] ;
         if ([GlobalDisplaySt sharedInstance].displayMode == 0) return ;
         
         self.editor.webView.userInteractionEnabled = num == -1 ;
         self.canBeEdited = num == -1 ;
         [UIView animateWithDuration:.1 animations:^{
             if (num == -1) self.btBack.transform = CGAffineTransformScale(self.btBack.transform, -1, 1) ;
             else self.btBack.transform = CGAffineTransformIdentity ;
         }] ;
         
         if (self.aNote == nil) {
             if (num == -1) {
                 self.emptyView.hidden = YES ;
                 [self.editor openKeyboard] ;
                 self.myBookID = self.delegate.currentBookID ;
                 self.editor.webViewHasSetMarkdown = YES ;
             }
             else {
                 self.emptyView.hidden = NO ;
             }
         }
         
         if (num == 0) {
             [self leaveOut] ;
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return YES ;
    
    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon != 1) {
        return YES ;
    }
    
    return [self.oct_panDelegate oct_gestureRecognizerShouldBegin:gestureRecognizer] ;
}

- (void)panned:(UIPanGestureRecognizer *)recognizer {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) return ;
    
    CGFloat velocity = [recognizer velocityInView:self.view].x ;
    switch ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon) {
        // 里层
        case -1: [self.pad_panDelegate pad_panned:recognizer] ; break;
        case 0: { // 中层
            if (velocity > 0) { //NSLog(@"👉") ;
                [self.oct_panDelegate oct_panned:recognizer] ; // 外层
            }
            else { //NSLog(@"👈") ;
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

- (void)leaveOut {
    if (!self.editor.webViewHasSetMarkdown) return ;
    if (self.editor.articleAreTheSame) return ;
    
    [self.editor leavePage] ;
    
    if (self.aNote) {
        // Update Your Note
        [self updateMyNote] ;
    }
    else {
        // Create New Note
        [self createNewNote] ;
    }
}



#pragma mark - Func

- (void)createNewNote {
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        NSString *title = [Note getTitleWithContent:markdown] ;
        
        if (markdown && markdown.length) {
            Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:markdown title:title] ;
            self.aNote = newNote ;
            [Note createNewNote:self.aNote] ;
            [self.delegate addNoteComplete:self.aNote] ;
        }
    }] ;
}

- (void)updateMyNote {
    if (!self.aNote) return ;
    if (!self.editor.webViewHasSetMarkdown) return ;
    if (self.editor.articleAreTheSame) return ;
    
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        NSString *title = [Note getTitleWithContent:markdown] ;
        
        self.aNote.content = markdown ;
        self.aNote.title = title ;
        [Note updateMyNote:self.aNote] ;
        [self.delegate editNoteComplete:self.aNote] ;
    }] ;
}

#pragma mark - UI

- (void)prepareUI {
    [self editor] ;
    self.editor.webView.userInteractionEnabled = self.canBeEdited ;
    self.editor.xt_theme_backgroundColor = k_md_bgColor ;
    self.editor.themeStr = [MDThemeConfiguration sharedInstance].currentThemeKey ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heightForBar.constant = APP_STATUSBAR_HEIGHT + 55 ;        
    }) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.btBack.xt_theme_imageColor = k_md_iconColor ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    [self.btBack xt_enlargeButtonsTouchArea] ;
    [self.btMore xt_enlargeButtonsTouchArea] ;
    
    self.navArea.backgroundColor = nil ;
    self.topBar.backgroundColor = nil ;

    [self.topBar setNeedsDisplay] ;
    [self.topBar layoutIfNeeded] ;
    [self.topBar oct_addBlurBg] ;
    
    [self registGesture] ;
    
    if (IS_IPAD) {
        [self.btBack setImage:[UIImage imageNamed:@"nav_back_reverse_item@2x"] forState:0] ;
    }
}

- (void)registGesture {
    __weak typeof(self)weakSelf = self;
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        if (direction == CWDrawerTransitionFromRight) { // 右侧滑出
            [weakSelf moreAction:nil];
        }
    }];
}

- (IBAction)backAction:(id)sender {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon) {
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_PullBack object:nil] ;
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
    _webView.backgroundColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
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

#pragma mark - prop

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [OctWebEditor sharedInstance] ;
        [self.view insertSubview:_editor atIndex:0] ;
        [_editor mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            } else {
                make.top.equalTo(self.view.xt_viewController.mas_topLayoutGuideBottom) ;
            }
            make.bottom.left.right.equalTo(self.view) ;
        }] ;
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
        [self.view addSubview:_emptyView] ;
        _emptyView.hidden = YES ;
    }
    return _emptyView ;
}

@end
