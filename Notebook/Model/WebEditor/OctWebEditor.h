//
//  OctWebEditor.h
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebModel.h"
#import "Note.h"
#import <WebKit/WebKit.h>

static NSString *const kNote_Editor_CHANGE = @"kNote_Editor_CHANGE" ;
static NSString *const kNote_Editor_Make_Big_Photo = @"kNote_Editor_Make_Big_Photo" ;

@interface OctWebEditor : UIView {
    CGFloat keyboardHeight ;
}
@property (strong, nonatomic) WKWebView *webView ;
@property (strong, nonatomic) WebModel  *webInfo ;
@property (copy, nonatomic)   NSArray   *typeInlineList ;
@property (nonatomic)         int       typePara ;

@property (nonatomic)         int       note_clientID ;
@property (strong, nonatomic) Note      *aNote ;
@property (copy, nonatomic)   NSString  *themeStr ;

- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(NSString *)json
                  completion:(void(^)(NSString *val, NSError *error))completion ;


- (void)getMarkdown:(void(^)(NSString *markdown))complete ;
- (void)getAllPhotos:(void(^)(NSString *json))complete ;

- (void)changeTheme ;
- (void)renderNote ;



@end


