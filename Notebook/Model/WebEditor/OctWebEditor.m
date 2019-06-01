//
//  OctWebEditor.m
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor.h"

@interface OctWebEditor () <UIWebViewDelegate>

@end

@implementation OctWebEditor

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createWebViewWithFrame:frame];
        [self setupHTMLEditor];
    }
    return self;
}

- (void)createWebViewWithFrame:(CGRect)frame
{
    NSAssert(!_webView, @"The web view must not exist when this method is called!");
    
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.opaque = NO;
    _webView.scrollView.bounces = NO;
//    _webView.usesGUIFixes = YES;
    _webView.keyboardDisplayRequiresUserAction = NO;
    _webView.scrollView.bounces = YES;
    _webView.allowsInlineMediaPlayback = YES;
//    [self startObservingWebViewContentSizeChanges];
    
    [self addSubview:_webView];
}

- (void)setupHTMLEditor
{
    NSBundle * bundle = [NSBundle bundleForClass:[self class]] ;
    NSURL * editorURL = [bundle URLForResource:@"test" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]];
}










/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
