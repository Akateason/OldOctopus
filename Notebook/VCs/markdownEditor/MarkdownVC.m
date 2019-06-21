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

@property (nonatomic)         BOOL              webSnapshotChecker ;
@property (strong, nonatomic) UIActivityIndicatorView *activityView ;
@end

@implementation MarkdownVC

#pragma mark - Life

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller {
    
    MarkdownVC *vc = [MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarddownVC"] ;
    vc.aNote = note ;
    vc.delegate = ctrller ;
    vc.myBookID = bookID ;
    [ctrller.navigationController pushViewController:vc animated:YES] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    
    if (self.aNote) {
        self.editor.aNote = self.aNote ;
    }

    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_CHANGE object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.6] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
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
     }] ;
    
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Editor_Make_Big_Photo object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSString *json = x.object ;
        [self snapShotFullScreen:json] ;
    }] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    [self.editor leavePage] ;
    if (!self.editor.webViewHasSetMarkdown) return ;
    if (self.editor.articleAreTheSame) return ;
    
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
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)moreAction:(id)sender {
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
    
    
    self.webSnapshotChecker = YES ;
    [_webView loadFileURL:url allowingReadAccessToURL:url] ;
//    NSURL *editorURL = [NSURL URLWithString:@"http://192.168.50.172:8887/mycode/pic.html"] ;
//    [_webView loadRequest:[NSURLRequest requestWithURL:editorURL]] ;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *body = message.body ;       // 就是 JS 调用 Native 时，传过来的 value
    NSLog(@"%@", body) ;
    NSDictionary *ret = [WebModel convertjsonStringToJsonObj:body] ;
    NSString *func = ret[@"method"] ;
    NSDictionary *jsonDic = ret[@"params"] ;
//    NSString *json = [jsonDic yy_modelToJSONString] ;
    NSLog(@"WebViewBridge func : %@\njson : %@",func,jsonDic) ;
    
    if ([func isEqualToString:@"readySnapshot"]) {
        if (self.webSnapshotChecker == NO) return ;
        
        self.webSnapshotChecker = NO ;

    }
    else if ([func isEqualToString:@"snapshotHeight"]) {
        float textHeight = [ret[@"params"] floatValue] ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.snapDuration = .2 + (float)textHeight / (float)APP_HEIGHT * .2 ;
            self.webView.height = textHeight ;
        
            
//            self.view.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + self.nail.height) ;
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
//                [SVProgressHUD dismiss] ;
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

@end
