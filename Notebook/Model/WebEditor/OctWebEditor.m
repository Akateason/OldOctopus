//
//  OctWebEditor.m
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"
#import <BlocksKit+UIKit.h>
#import "MDThemeConfiguration.h"
#import "WebPhotoHandler.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import "ArticlePhotoPreviewVC.h"
#import "AppDelegate.h"
#import "NHSlidingController.h"
#import "GlobalDisplaySt.h"
#import "SettingSave.h"
#import "MarkdownVC.h"
#import "HiddenUtil.h"
#import "OctShareCopyLinkView.h"
#import "HiddenUtil.h"
#import "HomePadVC.h"

@interface OctWebEditor () {
    NSArray<NSString *> *_disabledActions ;
    CGPoint             _contentOffsetBeforeScroll ;
    NSString            *_currentLinkUrl ;
    BOOL                _isFirstTimeLoad ;
}
@property (strong, nonatomic) RACSubject *editorCrashSignal ;

@end


@implementation OctWebEditor

XT_SINGLETON_M(OctWebEditor)

#pragma mark --
#pragma mark - life

- (void)setup {
    _isFirstTimeLoad = YES ;
    
    self.xt_theme_backgroundColor         = k_md_bgColor ;
    self.webView.xt_theme_backgroundColor = k_md_bgColor ;
    
    [self createWebView] ;
    [self setupHTMLEditor] ;
    
    _disabledActions = @[
                         [@[@"_", @"lo", @"oku", @"p", @":"] componentsJoinedByString:@""], // _lookup: 查询按钮
                         [@[@"_", @"s", @"har", @"e", @":"] componentsJoinedByString:@""], // _share:分享按钮
                         [@[@"_", @"d", @"e", @"fine", @":"] componentsJoinedByString:@""], // _define:Define
                         [@[@"_", @"ad", @"dS", @"hor", @"tcu", @"t:"] componentsJoinedByString:@""], // _addShortcut:学习...
                         [@[@"_", @"tr", @"ans", @"lit", @"era", @"te", @"Ch", @"ine", @"se", @":"] componentsJoinedByString:@""], // _transliterateChinese:简<=>繁
                         [@[@"_", @"re", @"ana", @"ly", @"ze", @":"] componentsJoinedByString:@""], // _reanalyze:分享按钮
                         ] ;
    
    // keyboard showing
    @weakify(self)
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] takeUntil:self.rac_willDeallocSignal] throttle:.02] deliverOnMainThread] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon && [GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) return ;
        if (!self.window) return ;
        
        NSDictionary *info = [x userInfo] ;
        CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        // 工具条的Y值 == 键盘的Y值 - 工具条的高度
        
        // get keyboard height
        self->keyboardHeight = APP_HEIGHT - (endKeyboardRect.origin.y - kOctEditorToolBarHeight) ;
        float param = (self->keyboardHeight == kOctEditorToolBarHeight) ? 0 : self->keyboardHeight ;
        if (!param) {
            [self.toolBar hideAllBoards] ;
            self.toolBar.hidden = YES ;
        }
        else {
            self.toolBar.top = 2000 ;
            self.toolBar.width = APP_WIDTH ;
            if (!self.toolBar.superview) [self.window addSubview:self.toolBar] ;
            
            [UIView animateWithDuration:.3 animations:^{
                if (endKeyboardRect.origin.y > self.height) { // 键盘的Y值已经远远超过了控制器view的高度
                    self.toolBar.top = self.height - kOctEditorToolBarHeight;
                }
                else {
                    self.toolBar.top = endKeyboardRect.origin.y - kOctEditorToolBarHeight;
                }
                NSLog(@"toolbar top : %f", self.toolBar.top) ;
                self.toolBar.hidden = NO ;
                [self.toolBar setNeedsLayout] ;
                [self.toolBar layoutIfNeeded] ;
            }] ;
        }
        
        if (self.toolBar.hidden == NO) {
            [self.toolBar refresh] ;
        }
        
        [self nativeCallJSWithFunc:@"setKeyboardHeight" json:@(param).stringValue completion:^(NSString *val, NSError *error) {}] ;
    }] ;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        self.toolBar.hidden = YES ;
        [self.toolBar hideAllBoards] ;
        self.toolBar.top = 2000 ;
    }] ;
    
    [[[RACSignal interval:5 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self)
        WebPhoto *photo = [WebPhoto xt_findWhere:XT_STR_FORMAT(@"fromNoteClientID == '%@'",self.aNote.icRecordName)].firstObject ;
        if (!photo) return ;
        
        NSData *imageData = [NSData dataWithContentsOfFile:photo.realPath] ;
        UIImage *image = [UIImage imageWithData:imageData] ;
        [self uploadWebPhoto:photo image:image] ;
    }] ;
    
    [[self.editorCrashSignal throttle:.6] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self reloadWKWebview] ;
    }] ;
}

- (void)setSideFlex {
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
        [self nativeCallJSWithFunc:@"setEditorFlex" json:@"28" completion:^(NSString *val, NSError *error) {}] ;
        self.sideWid = 28. ;
    }
    else if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon) {
        if ( ([GlobalDisplaySt sharedInstance].containerSize.width < [GlobalDisplaySt sharedInstance].containerSize.height) ) {
            float wid = [GlobalDisplaySt sharedInstance].containerSize.width / 4. ;
            [self nativeCallJSWithFunc:@"setEditorFlex" json:[@(wid) stringValue] completion:^(NSString *val, NSError *error) {}] ;
            self.sideWid = wid ;
        }
        else {
            float appWid = [GlobalDisplaySt sharedInstance].containerSize.width ?: APP_WIDTH ;
            float wid = ( appWid - ( appWid - kWidth_ListView - k_side_margin * 2. ) ) / 2. ;
            [self nativeCallJSWithFunc:@"setEditorFlex" json:[@(wid) stringValue] completion:^(NSString *val, NSError *error) {}] ;
            self.sideWid = wid ;
        }
    }
}


- (void)setEditable:(BOOL)editable {
    [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"setEditable" json:[@(editable) stringValue] completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)leavePage {
    self.webViewHasSetMarkdown = NO ;
    self.firstTimeArticle = nil ;
    
    // 清空undo redo
    [self nativeCallJSWithFunc:@"clearUndoRedoHistory" json:nil completion:^(NSString *val, NSError *error) {
    }] ;
    
    [self hideKeyboard] ;
}

- (void)createWebView {
    NSAssert(!_webView, @"The web view must not exist when this method is called!") ;
    WKWebViewConfiguration *config = [WKWebViewConfiguration new] ;
    [config.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"] ;
    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config] ;

    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    _webView.allowsBackForwardNavigationGestures = YES ;
    _webView.navigationDelegate = (id <WKNavigationDelegate>)self ;    
    _webView.opaque = NO ;
    [self addSubview:_webView] ;
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self) ;
    }] ;
    [_webView.configuration.userContentController addScriptMessageHandler:(id <WKScriptMessageHandler>)self name:@"WebViewBridge"] ;
}

// WKScriptMessageHandler delegate
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
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
            self.aNote.content = model.markdown ;
        }
        else {
            // 文章没改过, 不提交
//            self.articleAreTheSame = YES ;
        }
    }
    else if ([func isEqualToString:@"typeList"]) {
        NSArray *typelist = [WebModel currentTypeWithList:jsonDic[@"typeList"]] ;
        NSArray *listTypes = [WebModel currentTypeWithList:jsonDic[@"listTypes"]] ;
        NSMutableArray *tmpList = [typelist mutableCopy] ;
        [tmpList addObjectsFromArray:listTypes] ;
        self.typeBlkList = tmpList ;
    }
    else if ([func isEqualToString:@"formatList"]) {
        NSArray *list = [WebModel currentTypeWithList:jsonDic[@"formatList"]] ;
        self.typeInlineList = list ;
    }
    else if ([func isEqualToString:@"selectImage"]) {
        if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon && [GlobalDisplaySt sharedInstance].gdst_level_for_horizon != -1) return ;
        
        [self.toolBar hideAllBoards] ;
        self.toolBar.hidden = YES ;
        [self hideKeyboard] ;
        
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
    else if ([func isEqualToString:@"tapWebview"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
    }
    else if ([func isEqualToString:@"sendShareHtml"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Editor_Send_Share_Html object:ret[@"params"]] ;
    }
    else if ([func isEqualToString:@"editorCrash"]) {
        [self.editorCrashSignal sendNext:@1] ;
    }
    else if ([func isEqualToString:@"editorLink"]) {
        NSString *linkUrl = ret[@"params"] ;
        _currentLinkUrl = linkUrl ;
        if (linkUrl.length) {
            [self addMenu] ;
        }
        else {
            [self removeMenu] ;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.toolBar renderWithParaType:self.typeBlkList inlineList:self.typeInlineList] ;
    }) ;
}

- (void)setupHTMLEditor {
    if (![HiddenUtil getEditorLoadWay]) {
        //group
        NSString *path = XT_DOCUMENTS_PATH_TRAIL_(@"web/index.html") ;
        NSURL *fileURL = [NSURL fileURLWithPath:path] ;
        NSString *basePath = [XTArchive getDocumentsPath] ;
        NSURL *baseURL = [NSURL fileURLWithPath:basePath] ;
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:baseURL] ;
    }
    else {
        //link
        NSURL *editorURL = [NSURL URLWithString:[HiddenUtil developerMacLink]] ;
        [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]] ;
    }
}

- (void)setupJSCoreWhenFinishLoad {
    [self nativeCallJSWithFunc:@"setEditorTop" json:XT_STR_FORMAT(@"%@", @(55)) completion:^(NSString *val, NSError *error){}] ;
    
    [self setSideFlex] ;
    
    [self changeTheme] ;
    
    [self setupSettings] ;
    
    [self renderNote] ;
    
    [self nativeCallJSWithFunc:@"setEditorScrollOffset" json:@"0" completion:^(NSString *val, NSError *error) {}] ;
    
    if (_isFirstTimeLoad) {
        _isFirstTimeLoad = NO ;
    }
    else {
        if ( !self.aNote.content.length &&
            (
              [GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default ||
             (
              [GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 &&
              [GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon
              )
             )
            ) {
                 
                 [self openKeyboard] ;             
        }
    }
    
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon) {
        [self setEditable:NO] ;
    }
}

- (void)setupSettings {
    SettingSave *sSave = [SettingSave fetch] ;
    
    [self nativeCallJSWithFunc:@"setAutoAdBracket" json:[@(sSave.editor_autoAddBracket) stringValue] completion:^(NSString *val, NSError *error) {}] ;
    [self nativeCallJSWithFunc:@"setLineHeight" json:[@(sSave.editor_lightHeightRate) stringValue] completion:^(NSString *val, NSError *error) {}] ;
    [self nativeCallJSWithFunc:@"setUListSymbol" json:sSave.editor_md_ulistSymbol completion:^(NSString *val, NSError *error) {}] ;
    [self nativeCallJSWithFunc:@"setLooseList" json:[@(sSave.editor_isLooseList) stringValue] completion:^(NSString *val, NSError *error) {}] ;
}

#pragma mark --
#pragma mark - props

static const float kOctEditorToolBarHeight = 41. ;
- (OctToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [OctToolbar xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _toolBar.frame = CGRectMake(0, 2000, [self.class currentScreenBoundsDependOnOrientation].size.width, kOctEditorToolBarHeight) ;
        _toolBar.delegate = (id<OctToolbarDelegate>)self ;
        if (!_toolBar.superview) [self.window addSubview:_toolBar] ;
    }
    return _toolBar ;
}

- (void)setANote:(Note *)aNote {
    _aNote = aNote ;
    
    self.firstTimeArticle = aNote.content ;
    [self setupJSCoreWhenFinishLoad] ;
}

- (BOOL)articleAreTheSame {
    return [self.firstTimeArticle isEqualToString:self.aNote.content] ;
}

- (RACSubject *)editorCrashSignal {
    if(!_editorCrashSignal){
        _editorCrashSignal = ({
            RACSubject * object = [RACSubject subject] ;
            object;
        });
    }
    return _editorCrashSignal ;
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
//    NSLog(@"js : %@",js) ;
    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable val, NSError * _Nullable error) {
        NSLog(@"js:%@, val:%@",js,val) ;
        if (error) NSLog(@"%@", error) ;
        if (completion) completion(val, error) ;
    }] ;    
}

- (void)getMarkdown:(void(^)(NSString *markdown))complete {
    [self nativeCallJSWithFunc:@"getMarkdown" json:nil completion:^(NSString *val, NSError *error) {
        if ([val isEqualToString:@"\n"]) val = nil ;
        complete(val) ;
    }] ;
}

- (void)getAllPhotos:(void(^)(NSString *json))complete {
    [self nativeCallJSWithFunc:@"getAllPhotos" json:nil completion:^(NSString *val, NSError *error) {
        complete(val) ;
    }] ;
}

- (void)renderNote {
    NSLog(@"renderNote setMarkdown : %@",self.aNote.content) ;
    WEAK_SELF
//    NSDictionary *dic = @{@"markdown":weakSelf.aNote.content ?: @"", @"isRenderCursor": @(self.isCreateNew) } ;
    NSDictionary *dic = @{@"markdown":weakSelf.aNote.content ?: @"", @"isRenderCursor": @0 } ;
    [self nativeCallJSWithFunc:@"setMarkdown" json:dic completion:^(NSString *val, NSError *error) {
        if (!error) {
            weakSelf.webViewHasSetMarkdown = YES ;
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
        [self enableKeyboardDisplayAutomatically] ;
        [self disableAdjustScrollViewWithKeyboardChange] ;
        
        [self removeInputAccessoryViewFromWKWebView:webView] ;
        [self hookWKContentViewFuncCanPerformAction] ;
        
        
        [self.toolBar setNeedsLayout] ;
        [self.toolBar layoutIfNeeded] ;
        [self.toolBar reset] ;
    }) ;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error: %@",error) ;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error: %@",error) ;
}

#pragma mark --
#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.contentOffset = _contentOffsetBeforeScroll;
    scrollView.delegate = nil;
}

#pragma mark --
#pragma mark - util

- (BOOL)typeBlkListHasThisType:(int)type {
    bool hasType = NO ;
    for (NSNumber *num in self.typeBlkList) {
        if ([num intValue] == type) hasType = YES ;
    }
    return hasType ;
}


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


/**
 类似于 UIWebView 的 keyboardDisplayRequiresUserAction 属性
 */
- (void)enableKeyboardDisplayAutomatically {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
    NSOperatingSystemVersion iOS_12_2_0 = (NSOperatingSystemVersion){12, 2, 0};
    NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS_11_3_0]) {
        SEL selector;
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {
            selector =
            sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:");
        } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_12_2_0]) {
            selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
            
        } else {
            selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        }
        
        Method method = class_getInstanceMethod(class, selector);
        if (method) {
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void *arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
                WKWebView *webView = [me valueForKey:@"_webView"];
                if ([webView.superview isKindOfClass:[OctWebEditor class]]) {
                    [self disableAdjustScrollViewWithUserInteracting:me];
                    ((void (*)(id, SEL, void *, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
                } else {
                    ((void (*)(id, SEL, void *, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, arg1, arg2, arg3, arg4);
                }
            });
            method_setImplementation(method, override);
        }
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        if (method) {
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void *arg0, BOOL arg1, BOOL arg2, id arg3) {
                WKWebView *webView = [me valueForKey:@"_webView"];
                if ([webView.superview isKindOfClass:[OctWebEditor class]]) {
                    [self disableAdjustScrollViewWithUserInteracting:me];
                    ((void (*)(id, SEL, void *, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
                } else {
                    ((void (*)(id, SEL, void *, BOOL, BOOL, id))original)(me, selector, arg0, arg1, arg2, arg3);
                }
            });
            method_setImplementation(method, override);
        }
    }
}

// 禁止键盘弹起时滚动 webView
- (void)disableAdjustScrollViewWithUserInteracting:(id)contentView
{
    WKWebView *webView = [contentView valueForKey:@"_webView"];
    _contentOffsetBeforeScroll = webView.scrollView.contentOffset;
    webView.scrollView.delegate = self;
}

/**
 禁止 WebView 跟随键盘调整 ScrollView 的尺寸
 */
- (void)disableAdjustScrollViewWithKeyboardChange {
    Class class = NSClassFromString(@"WKWebView");
    SEL selector = sel_getUid("_keyboardChangedWithInfo:adjustScrollView:");
    Method method = class_getInstanceMethod(class, selector);
    IMP original = method_getImplementation(method);
    IMP override = imp_implementationWithBlock(^void(id me, id arg0, BOOL arg1) {
        WKWebView *webView = me;
        if ([webView.superview isKindOfClass:[OctWebEditor class]]) {
            ((void (*)(id, SEL, id, BOOL))original)(me, selector, arg0, NO);
        } else {
            ((void (*)(id, SEL, id, BOOL))original)(me, selector, arg0, arg1);
        }
    });
    method_setImplementation(method, override);
}


// hook canPerformAction:withSender
- (void)hookWKContentViewFuncCanPerformAction {
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
                return NO; // 本来是yes, 现在屏蔽选择,调用web接口实现选择.
            }
            else if ([self isDisabledAction:action]) {
                return NO;
            }
            else {
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

- (void)getShareHtml {
    [self getShareHtmlWithMd:nil] ;
}

- (void)getShareHtmlWithMd:(NSString *)md {
    [self nativeCallJSWithFunc:@"getShareHtml" json:md completion:^(NSString *val, NSError *error) {
    }] ;
}


- (void)reloadWKWebview {
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    
    [SVProgressHUD showErrorWithStatus:@"系统出现异常,自动刷新页面"] ;
    
    [self.toolBar removeFromSuperview] ;
    _toolBar = nil ;
    
    [_webView removeFromSuperview] ;
    _webView = nil ;
    
    [self setup] ;
    
    [self renderNote] ;
}

#pragma mark - MENU controller

- (void)addMenu {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = @[[[UIMenuItem alloc] initWithTitle:@"跳转" action:@selector(jumpLink:)]] ;
}

- (void)removeMenu {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = nil ;
    [self hookWKContentViewFuncCanPerformAction] ;
}

- (void)jumpLink:(UIMenuController *)menu {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_currentLinkUrl]];
}

//监听事情需要对应的方法 冒号之后传入的是UIMenuController
//- (void)cut:(UIMenuController *)menu {
//    NSLog(@"%s %@", __func__, menu);
//}
//
//- (void)copy:(UIMenuController *)menu {
//    NSLog(@"%s %@", __func__, menu);
//}
//
//- (void)paste:(UIMenuController *)menu {
//    NSLog(@"%s %@", __func__, menu);
//}
//
//- (void)select:(UIMenuController *)menu {
//    NSLog(@"%s %@", __func__, menu);
//}

- (void)selectAll:(UIMenuController *)menu {
    NSLog(@"%s %@", __func__, menu);
    [self nativeCallJSWithFunc:@"selectAll" json:nil completion:^(NSString *val, NSError *error) {
    }] ;
}




@end
