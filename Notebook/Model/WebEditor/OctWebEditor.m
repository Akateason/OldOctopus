//
//  OctWebEditor.m
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"
#import "UIWebView+GUIFixes.h"
#import <XTlib/XTlib.h>
#import "OctToolbar.h"
#import <BlocksKit+UIKit.h>

@interface OctWebEditor () <UIWebViewDelegate,OctToolbarDelegate>
@property (strong, nonatomic) OctToolbar    *toolBar ;
@property (strong, nonatomic) JSContext     *context ;
@end


@implementation OctWebEditor

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createWebViewWithFrame:frame];
        [self setupHTMLEditor];
        
        // keyboard showing
        @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *_Nullable x) {
            @strongify(self)
            NSDictionary *info = [x userInfo] ;
            CGSize kbSize      = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size ;
            // get keyboard height
            self->keyboardHeight = kbSize.height ;
        }];
        
    }
    return self;
}

- (void)createWebViewWithFrame:(CGRect)frame {
    NSAssert(!_webView, @"The web view must not exist when this method is called!");
    
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    _webView.scalesPageToFit = NO;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.opaque = NO;
    _webView.scrollView.bounces = NO;
    _webView.usesGUIFixes = YES;
    _webView.keyboardDisplayRequiresUserAction = NO;
    _webView.scrollView.bounces = YES;
    _webView.allowsInlineMediaPlayback = YES;

    [self addSubview:_webView];
}

- (void)setupHTMLEditor {
    //group
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]] ;
//    NSURL *editorURL = [bundle URLForResource:@"index" withExtension:@"html"] ;
    //refence
//    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] ;
//    NSURL *editorURL = [NSURL fileURLWithPath:basePath isDirectory:YES] ;
    //link
    NSURL *editorURL = [NSURL URLWithString:@"http://192.168.50.172:3000/"] ;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]] ;
}

- (void)setupJSCore {
    self.context[@"WebViewBridge"] = self;

//    WebViewBridge
//    @weakify(self)
    self.context[@"WebViewBridge"] = ^(JSValue *func, JSValue *json) {
//        @strongify(self)
        NSLog(@"WebViewBridge func : %@\njson : %@",func,json) ;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.toolBar refresh] ;
//        }) ;
    } ;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES ;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [context setExceptionHandler:^(JSContext *ctx, JSValue *expectValue) {
        NSLog(@"js core err : %@", expectValue);
    }];
    
    self.context = context;
    [self setupJSCore] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView.customInputAccessoryView = self.toolBar ;
        [self.toolBar setNeedsLayout] ;
        [self.toolBar layoutIfNeeded] ;
        [self.toolBar refresh] ;
    }) ;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"err : %@",error) ;
}

- (OctToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [OctToolbar xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _toolBar.frame = CGRectMake(0, 0, [self.class currentScreenBoundsDependOnOrientation].size.width, 41) ;
        _toolBar.delegate = self ;
    }
    return _toolBar ;
}

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(NSString *)json
            getCompletionVal:(void(^)(JSValue *val))completion {
    
    json = !json ? @"" : json ;
    JSValue *jsFun = self.context[@"WebViewBridgeCallback"];
    NSArray *args = @[[@{@"method":func} yy_modelToJSONString], json] ;
    
    BOOL callStraight = [func isEqualToString:@"getMarkdown"] || [func isEqualToString:@"getAllPhotos"] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //使用js的window.setTimeout方法执行需要调用的方法
        JSValue *n ;
        if (callStraight) {
            n = [jsFun callWithArguments:args] ;
        }
        else {
            n = [jsFun.context[@"setTimeout"] callWithArguments:@[jsFun, @0, [@{@"method":func} yy_modelToJSONString], json]] ;
        }
        if (completion) completion(n) ;
    });
}

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(NSString *)json
                  completion:(void(^)(BOOL isComplete))completion {
    [self nativeCallJSWithFunc:func json:json getCompletionVal:^(JSValue *val) {
        if (completion) completion(val.toBool) ;
    }] ;
}

- (void)getMarkdown:(void(^)(NSString *markdown))complete {
    [self nativeCallJSWithFunc:@"getMarkdown" json:nil getCompletionVal:^(JSValue *val) {
        complete(val.toString) ;
    }] ;
}

- (void)getAllPhotos:(void(^)(NSString *json))complete {    
    [self nativeCallJSWithFunc:@"getAllPhotos" json:nil getCompletionVal:^(JSValue *val) {
        complete(val.toString) ;
    }] ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
