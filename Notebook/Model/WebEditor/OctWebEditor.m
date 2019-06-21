//
//  OctWebEditor.m
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"
#import "OctToolbar.h"
#import <BlocksKit+UIKit.h>
#import "MDThemeConfiguration.h"
#import "WebPhotoHandler.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import "ArticlePhotoPreviewVC.h"
#import "AppDelegate.h"


@interface OctWebEditor () {
    NSArray<NSString *> *_disabledActions ;
}
@property (strong, nonatomic) OctToolbar    *toolBar ;
@property (copy, nonatomic) NSString *firstTimeArticle ;
@end


@implementation OctWebEditor

XT_SINGLETON_M(OctWebEditor)

#pragma mark --
#pragma mark - life
- (void)setup {
    self.backgroundColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
    
    [self createWebView] ;
    [self setupHTMLEditor] ;
    
    _disabledActions = @[
                         [@[@"_", @"lo", @"oku", @"p", @":"] componentsJoinedByString:@""], // _lookup: 查询按钮
                         [@[@"_", @"s", @"har", @"e", @":"] componentsJoinedByString:@""], // _share:分享按钮
                         [@[@"_", @"d", @"e", @"fine", @":"] componentsJoinedByString:@""], // _define:Define
                         [@[@"_", @"ad", @"dS", @"hor", @"tcu", @"t:"] componentsJoinedByString:@""], // _addShortcut:学习...
                         [@[@"_", @"tr", @"ans", @"lit", @"era", @"te", @"Ch", @"ine", @"se", @":"] componentsJoinedByString:@""], // _transliterateChinese:简<=>繁
                         [@[@"_", @"re", @"ana", @"ly", @"ze", @":"] componentsJoinedByString:@""] // _reanalyze:分享按钮
                         ] ;
    
    // keyboard showing
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        NSDictionary *info = [x userInfo] ;
        //            CGRect beginKeyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        // 工具条的Y值 == 键盘的Y值 - 工具条的高度
        if (endKeyboardRect.origin.y > self.height) { // 键盘的Y值已经远远超过了控制器view的高度
            self.toolBar.top = self.height - kOctEditorToolBarHeight;
        }
        else {
            self.toolBar.top = endKeyboardRect.origin.y - kOctEditorToolBarHeight;
        }
        
        self.toolBar.width = APP_WIDTH ;
        if (!self.toolBar.superview) [self.window addSubview:self.toolBar] ;
        self.toolBar.hidden = NO ;
        
        // get keyboard height
        self->keyboardHeight = APP_HEIGHT - (endKeyboardRect.origin.y - kOctEditorToolBarHeight) ;
        float param = (self->keyboardHeight == kOctEditorToolBarHeight) ? 0 : self->keyboardHeight ;
        
        
        [self nativeCallJSWithFunc:@"setKeyboardHeight" json:@(param).stringValue completion:^(NSString *val, NSError *error) {
        }] ;
        
        
    }] ;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        self.toolBar.hidden = YES ;
    }] ;
    
    [[[RACSignal interval:5 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self)
        WebPhoto *photo = [WebPhoto xt_findWhere:XT_STR_FORMAT(@"fromNoteClientID == '%@'",self.aNote.icRecordName)].firstObject ;
        if (!photo) return ;
        
        NSData *imageData = [NSData dataWithContentsOfFile:photo.localPath] ;
        UIImage *image = [UIImage imageWithData:imageData] ;
        [self uploadWebPhoto:photo image:image] ;
    }] ;
}

- (void)leavePage {
    [self hideKeyboard] ;
    self.articleAreTheSame = NO ;
    self.webViewHasSetMarkdown = NO ;
    self.aNote = nil ;
}

- (void)createWebView {
    NSAssert(!_webView, @"The web view must not exist when this method is called!") ;
    WKWebViewConfiguration *config = [WKWebViewConfiguration new] ;
    [config.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"] ;
    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config] ;

    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    _webView.navigationDelegate = (id <WKNavigationDelegate>)self ;
    _webView.backgroundColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
    _webView.opaque = NO ;
    [self addSubview:_webView] ;
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self) ;
    }] ;
    [_webView.configuration.userContentController addScriptMessageHandler:(id <WKScriptMessageHandler>)self name:@"WebViewBridge"] ;
}

// WKScriptMessageHandler delegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//    NSString *name = message.name ; // 就是上边注入到 JS 的哪个名字，在这里是 nativeMethod
    NSString *body = message.body ;       // 就是 JS 调用 Native 时，传过来的 value
    NSLog(@"%@", body) ;
    NSDictionary *ret = [WebModel convertjsonStringToJsonObj:body] ;
    NSString *func = ret[@"method"] ;
    NSDictionary *jsonDic = ret[@"params"] ;
    NSString *json = [jsonDic yy_modelToJSONString] ;
    NSLog(@"WebViewBridge func : %@\njson : %@",func,jsonDic) ;
    
    if ([func isEqualToString:@"change"]) {
        WebModel *model = [WebModel yy_modelWithJSON:jsonDic] ;
        self.webInfo = model ;
        if (![model.markdown isEqualToString:@"\n"] && self.webViewHasSetMarkdown && ![model.markdown isEqualToString:self.firstTimeArticle]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Editor_CHANGE object:model.markdown] ;
            self.articleAreTheSame = NO ;
        }
        else {
            // 文章没改过, 不提交
            self.articleAreTheSame = YES ;
        }
    }
    else if ([func isEqualToString:@"typeList"]) {
        NSArray *typelist = [WebModel currentTypeWithList:json] ;
        self.typePara = [typelist.firstObject intValue] ;
    }
    else if ([func isEqualToString:@"formatList"]) {
        NSArray *list = [WebModel currentTypeWithList:json] ;
        self.typeInlineList = list ;
    }
    else if ([func isEqualToString:@"selectImage"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WEAK_SELF
            [ArticlePhotoPreviewVC showFromView:self.window json:json deleteOnClick:^(ArticlePhotoPreviewVC * _Nonnull vc) {
                [vc removeFromSuperview] ;
                [weakSelf nativeCallJSWithFunc:@"deleteImage" json:jsonDic completion:^(NSString *val, NSError *error) {
                }] ;
            }] ;
        }) ;
    }
    else if ([func isEqualToString:@"setPureHtml"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Editor_Make_Big_Photo object:ret[@"params"]] ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.toolBar refresh] ;
        [self.toolBar renderWithParaType:self.typePara inlineList:self.typeInlineList] ;
    }) ;
}

- (void)setupHTMLEditor {
    if (!g_isLoadWebViewOnline) {
        //group
        NSString *path = XT_DOCUMENTS_PATH_TRAIL_(@"web/index.html") ;
        NSURL *fileURL = [NSURL fileURLWithPath:path] ;
        NSString *basePath = [XTArchive getDocumentsPath] ;
        NSURL *baseURL = [NSURL fileURLWithPath:basePath] ;
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:baseURL] ;
    }
    else {
        //link
        NSURL *editorURL = [NSURL URLWithString:@"http://192.168.50.172:3000/"] ;
//        NSURL *editorURL = [NSURL URLWithString:@"http://192.168.50.172:8887/mycode/pic.html"] ;
        [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]] ;
    }
}

- (void)setupJSCoreWhenFinishLoad {
    [self nativeCallJSWithFunc:@"setEditorTop" json:XT_STR_FORMAT(@"%@", @(55)) completion:^(NSString *val, NSError *error) {
    }] ;
    
    [self changeTheme] ;
    
    [self renderNote] ;
    
    if (!self.aNote) {
        [self nativeCallJSWithFunc:@"openKeyboard" json:nil completion:^(NSString *val, NSError *error) {
        }] ;
    }
}

#pragma mark --
#pragma mark - props

static const float kOctEditorToolBarHeight = 41. ;
- (OctToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [OctToolbar xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _toolBar.frame = CGRectMake(0, 2000, [self.class currentScreenBoundsDependOnOrientation].size.width, kOctEditorToolBarHeight) ;
        _toolBar.delegate = (id<OctToolbarDelegate>)self ;
    }
    return _toolBar ;
}

- (void)setANote:(Note *)aNote {
    _aNote = aNote ;
    
    [self setupJSCoreWhenFinishLoad] ;
}

#pragma mark --
#pragma mark - func

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(id)obj
                  completion:(void(^)(NSString *val, NSError *error))completion {
    
    NSString *json ;
    if ([obj isKindOfClass:[NSString class]]) {
        json = obj ;
        json = [json stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] ;
        json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] ;
        json = [json stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"] ;
        json = [json stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"] ;
        json = [json stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"] ;
        json = [json stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"] ;
        json = [json stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"] ;
        json = XT_STR_FORMAT(@"'%@'",json) ;
    }
    else {
        json = [obj yy_modelToJSONString] ;
    }
    json = !json ? @"''" : json ;
    
    NSString *js = XT_STR_FORMAT(@"WebViewBridgeCallback({\"method\":\"%@\"}, %@)",func,json) ;
    NSLog(@"js : %@",js) ;
    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable val, NSError * _Nullable error) {
        NSLog(@"%@ \nerr : %@", val, error) ;
        if (completion) completion(val, error) ;
    }] ;    
}

- (void)getMarkdown:(void(^)(NSString *markdown))complete {
    [self nativeCallJSWithFunc:@"getMarkdown" json:nil completion:^(NSString *val, NSError *error) {
        complete(val) ;
    }] ;
}

- (void)getAllPhotos:(void(^)(NSString *json))complete {
    [self nativeCallJSWithFunc:@"getAllPhotos" json:nil completion:^(NSString *val, NSError *error) {
        complete(val) ;
    }] ;
}

- (void)renderNote {
    if (!self.aNote) return ;
    
    WEAK_SELF
    [self nativeCallJSWithFunc:@"setMarkdown" json:self.aNote.content completion:^(NSString *val, NSError *error) {
        if (!error) {
            if (weakSelf.firstTimeArticle == nil) {
                weakSelf.firstTimeArticle = weakSelf.aNote.content ;
                weakSelf.webViewHasSetMarkdown = YES ;
            }
        }
    }] ;
}

- (void)changeTheme {
    [self nativeCallJSWithFunc:@"setTheme" json:self.themeStr ?: @"light" completion:^(NSString *val, NSError *error) {
    
    }] ;
}

#pragma mark --
#pragma mark - wkwebview delegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self setupJSCoreWhenFinishLoad] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeInputAccessoryViewFromWKWebView:webView] ;
        [self enableSelectAll] ;
        
        [self.toolBar setNeedsLayout] ;
        [self.toolBar layoutIfNeeded] ;
        [self.toolBar refresh] ;
    }) ;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}


#pragma mark --
#pragma mark - util

/**
 隐藏 webview 的 inputAccessoryView
 */
- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView {
    UIView *targetView;
    for (UIView *view in webView.scrollView.subviews) {
        if([[view.class description] hasPrefix:@"WKContent"]) {
            targetView = view;
        }
    }
    if (!targetView) {
        return;
    }
    NSString *noInputAccessoryViewClassName = [NSString stringWithFormat:@"%@_NoInputAccessoryView", targetView.class.superclass];
    Class newClass = NSClassFromString(noInputAccessoryViewClassName);
    if(newClass == nil) {
        newClass = objc_allocateClassPair(targetView.class, [noInputAccessoryViewClassName cStringUsingEncoding:NSASCIIStringEncoding], 0);
        if(!newClass) {
            return;
        }
        Method method = class_getInstanceMethod([self class], @selector(inputAccessoryView));
        class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));
        objc_registerClassPair(newClass);
    }
    object_setClass(targetView, newClass);
}


- (void)enableSelectAll {
    Class class = NSClassFromString(@"WKContentView");
    SEL selector = sel_getUid("canPerformActionForWebView:withSender:");
    Method method = class_getInstanceMethod(class, selector);
    
    if (!method) {
        selector = sel_getUid("canPerformAction:withSender:");
        method = class_getInstanceMethod(class, selector);
    }
    
    if (method) {
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^BOOL(id me, SEL action, id sender) {
            if (action == @selector(selectAll:)) {
                return YES;
            } else if ([self isDisabledAction:action]) {
                return NO;
            } else {
                return ((BOOL (*)(id, SEL, SEL, id))original)(me, selector, action, sender);
            }
        });
        method_setImplementation(method, override);
    }
}

- (BOOL)isDisabledAction:(SEL) action {
    for (int i = 0; i < [_disabledActions count]; i++) {
        if ([[_disabledActions objectAtIndex:i] isEqualToString:NSStringFromSelector(action)]) {
            return YES;
        }
    }
    return NO;
}

@end
