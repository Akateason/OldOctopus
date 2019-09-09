//
//  _NoInputAccessoryView.h
//  Notebook
//
//  Created by teason23 on 2019/9/9.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface _NoInputAccessoryView : NSObject

- (id)inputAccessoryView ;
- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView ;

@end

NS_ASSUME_NONNULL_END
