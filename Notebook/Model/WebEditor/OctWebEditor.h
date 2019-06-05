//
//  OctWebEditor.h
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>



@interface OctWebEditor : UIView {
    CGFloat     keyboardHeight ;
}
@property (strong, nonatomic) UIWebView *webView ;

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(NSString *)json
                  completion:(void(^)(BOOL isComplete))completion ;

@end


