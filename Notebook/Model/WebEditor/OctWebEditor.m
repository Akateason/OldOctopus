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

@interface OctWebEditor () <UIWebViewDelegate,OctToolbarDelegate>
@property (strong, nonatomic) OctToolbar    *toolBar ;
@end


@implementation OctWebEditor

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createWebViewWithFrame:frame];
        [self setupHTMLEditor];
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
    NSBundle *bundle = [NSBundle bundleForClass:[self class]] ;
    NSURL *editorURL = [bundle URLForResource:@"index" withExtension:@"html"] ;    //file:///Users/teason23/Library/Developer/CoreSimulator/Devices/9A0690D2-F81F-4239-8966-2D9D6DCD1F96/data/Containers/Bundle/Application/588FF939-567D-4B36-9C1C-1A4E86C2277D/Notebook.app/index.html

    
//    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] ;
//    NSURL *editorURL = [NSURL fileURLWithPath:basePath isDirectory:YES] ;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]] ;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES ;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"err : %@",error) ;
}

//- (BOOL)canBecomeFirstResponder {
//    [self.toolBar refresh] ;
//    self.webView.customInputAccessoryView = self.toolBar ;
//    // Redraw in case enabbled features have changes
//    return [super canBecomeFirstResponder] ;
//}

- (OctToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [OctToolbar xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        _toolBar.frame = CGRectMake(0, 0, [self.class currentScreenBoundsDependOnOrientation].size.width, 41) ;
        _toolBar.delegate = self ;
    }
    return _toolBar ;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
