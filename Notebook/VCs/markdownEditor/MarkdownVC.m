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


@interface MarkdownVC ()
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

@property (nonatomic) BOOL thisArticleHasChanged ;
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
        if (!self.thisArticleHasChanged) self.thisArticleHasChanged = YES ;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
    
    if (self.aNote) {
        // Update Your Note
        if (self.thisArticleHasChanged) [self updateMyNote] ;
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
        NSString *articleContent = markdown ;
        NSArray *listForBreak = [markdown componentsSeparatedByString:@"\n"] ;
        NSString *title = @"无标题" ;
        for (NSString *str in listForBreak) {
            if (str.length) {
                title = str ;
                break ;
            }
        }
        
        if (articleContent && articleContent.length) {
            Note *newNote = [[Note alloc] initWithBookID:self.myBookID content:articleContent title:title] ;
            self.aNote = newNote ;
            [Note createNewNote:self.aNote] ;
            [self.delegate addNoteComplete:self.aNote] ;
        }
    }] ;
    
}

- (void)updateMyNote {
    if (!self.aNote) return ;
    
    @weakify(self)
    [self.editor getMarkdown:^(NSString *markdown) {
        @strongify(self)
        NSArray *listForBreak = [markdown componentsSeparatedByString:@"\n"] ;
        NSString *title = @"无标题" ;
        for (NSString *str in listForBreak) {
            if (str.length) {
                title = str ;
                break ;
            }
        }
        
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
    
    // 预览
    self.infoVC.blkOutput = ^{
        [weakSelf.editor hideKeyboard] ;
        [weakSelf.editor nativeCallJSWithFunc:@"getPureHtml" json:nil completion:^(NSString *val, NSError *error) {}] ;
    } ;
    
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:[ArticleInfoVC movingDistance] maskAlpha:0.4 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil] ;
    [self cw_showDrawerViewController:self.infoVC animationType:0 configuration:conf] ;
}

- (void)snapShotFullScreen:(NSString *)htmlString {
    [self dismissViewControllerAnimated:YES completion:nil] ;
    
    self.editor.hidden = YES ;
    
    NSMutableString *tmpStr = [htmlString mutableCopy] ;
    htmlString = [tmpStr stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"] ;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""] ;
    
//    UIWebView *webView = [[UIWebView alloc] init] ;
//    webView.delegate = self ;
    WKWebView *webView = [[WKWebView alloc] init] ;
    webView.navigationDelegate = (id<WKNavigationDelegate>)self ;
    [webView loadHTMLString:htmlString baseURL:nil] ;
    webView.frame = self.view.bounds ;
    [self.view addSubview:webView] ;
}

#pragma mark - wkWeb for Photo
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
            NSLog(@"value : %@",value) ;
            [self makeSnapshot:webView height:[value floatValue]] ;
        }] ;
    }) ;
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
////            NSLog(@"value : %@",value) ;
//            [self makeSnapshot:webView height:1000] ;
////        }] ;
////    }) ;
//}


- (void)makeSnapshot:(UIWebView *)webview height:(float)height {
    __block UIWebView *webView = webview ;
    float textHeight = height ;
    webView.height = height ;
    [webView setNeedsLayout] ;
    [webView layoutIfNeeded] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        OutputPreviewsNailView *nail = [OutputPreviewsNailView makeANail] ;
        nail.top = textHeight ;
        [self.view addSubview:nail] ;
        
        self.view.frame = CGRectMake(0, 0, APP_WIDTH , textHeight + nail.height) ;
        [self.view setNeedsLayout] ;
        [self.view layoutIfNeeded] ;
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false,  [UIScreen mainScreen].scale) ;
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()] ;
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
        UIGraphicsEndImageContext() ;

        [nail removeFromSuperview] ;
        [webView removeFromSuperview] ;
        webView = nil ;
        nail = nil ;
        self.editor.hidden = NO ;
        
        if (!image) return ;
        
        [OutputPreviewVC showFromCtrller:self imageOutput:image] ;
    }) ;
}

#pragma mark - prop

- (OctWebEditor *)editor {
    if (!_editor) {
        _editor = [[OctWebEditor alloc] init] ;
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
