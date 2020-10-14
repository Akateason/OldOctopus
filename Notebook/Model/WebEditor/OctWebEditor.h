//
//  OctWebEditor.h
//  Notebook
//
//  Created by teason23 on 2019/5/31.
//  Copyright © 2019 teason23. All rights reserved.
//
// octopus Editor in webkit
// 编辑器对接文档参考 https://shimo.im/docs/eVMAPV2N649cmqg8
// SINGLETON

#import <UIKit/UIKit.h>
#import "WebModel.h"
#import "Note.h"
#import <WebKit/WebKit.h>
#import <XTlib/XTlib.h>
#import "OctToolbar.h"

static const float k_side_margin = 100. ;

@interface OctWebEditor : UIView {
    CGFloat keyboardHeight ;
}

+ (instancetype)currentOctWebEditor;

#pragma mark - Func
/**
 Native call JS.
 @param func 方法名
 @param obj 当obj 是 json时, 传入NSDictionary或NSArray 类型 , 默认传String
 @param completion 结果
 */
- (void)nativeCallJSWithFunc:(NSString *)func
                        json:(id)obj
                  completion:(void(^)(NSString *val, NSError *error))completion ;


#pragma mark - public

- (void)getMarkdown:(void(^)(NSString *markdown))complete ;
- (void)getAllPhotos:(void(^)(NSString *json))complete ;
- (void)setupSettings ;
- (void)changeTheme ;
- (void)renderNote ;
- (void)setSideFlex ;
- (void)setEditable:(BOOL)editable ;
- (void)getShareHtml ;
- (void)getShareHtmlWithMd:(NSString *)md ;
- (BOOL)typeBlkListHasThisType:(int)type ;


#pragma mark - life

// initial
- (void)setup ;
// close
- (void)leavePage ;



#pragma mark - props

@property (strong, nonatomic) WKWebView     *webView ;
@property (strong, nonatomic) WebModel      *webInfo ;
@property (copy, nonatomic)   NSArray       *typeInlineList ;
@property (copy, nonatomic)   NSArray       *typeBlkList ;
@property (strong, nonatomic) OctToolbar    *toolBar ;

@property (nonatomic)         int           note_clientID ;
@property (strong, nonatomic) Note          *aNote ;
@property (copy, nonatomic)   NSString      *themeStr ;

- (BOOL)articleAreTheSame ; //如果文章比对一致不能上传      default NO
@property (nonatomic)         BOOL          webViewHasSetMarkdown ; //如果未setMarkdown则不能上传  default NO
@property (copy, nonatomic) NSString        *firstTimeArticle ; // 首次文章比对
@property (nonatomic)       float           sideWid ;

@end


