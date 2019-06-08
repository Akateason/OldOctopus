//
//  OctWebEditor.h
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebModel.h"
#import "Note.h"


@interface OctWebEditor : UIView {
    CGFloat keyboardHeight ;
}
@property (strong, nonatomic) UIWebView *webView ;
@property (strong, nonatomic) WebModel  *webInfo ;
@property (nonatomic)         int       note_clientID ;
@property (strong, nonatomic) Note      *aNote ;
@property (copy, nonatomic)   NSString  *themeStr ;

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(NSString *)json
                  completion:(void(^)(BOOL isComplete))completion ;

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(NSString *)json
            getCompletionVal:(void(^)(JSValue *val))completion ;


- (void)getMarkdown:(void(^)(NSString *markdown))complete ;
- (void)getAllPhotos:(void(^)(NSString *json))complete ;

- (void)changeTheme ;
- (void)renderNote ;
@end


