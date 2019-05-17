//
//  MarkdownModel.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//
//  This is a paragraph Model
//  when in a container , type is block or not.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MdParserRegexpHeader.h"
#import "MDThemeConfiguration.h"

@class MarkdownEditor ;

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownModel : NSObject

@property (nonatomic)           NSRange         range ;
@property (nonatomic)           int             type ;
@property (copy, nonatomic)     NSString        *str ;
@property (nonatomic)           BOOL            isOnEditState ; // yes - edit, no - preview  . state for display
@property (copy, nonatomic)     NSArray         *inlineModels ;

// 引用 列表 嵌套
@property (nonatomic) int textIndentationPosition ; // 文字缩进的位置  , 一共有多少嵌套, 缩进多少
@property (nonatomic) int markIndentationPosition ; // 绘制mark的位置,  当前model的mark在第几个层级
@property (nonatomic) int quoteAndList_Level ;      // 单行内 所对应的层级(只记录引用和列表) 最外层未0, 然后递增
@property (nonatomic) int wholeNestCountForquoteAndList ;    // (只取最外层), 此行, 一共有多少层级嵌套.(只记录引用和列表)
@property (strong, nonatomic)   MarkdownModel   *subBlkModel ;

// 段前,段后(根据标题划分) 对应的行高, 分为3种类型, 0普通, 1小(段前,段落文字前面), 2大(段后,标题前面)
@property (nonatomic) int paraBeginEndSpaceOffset ;
- (CGFloat)valueOfparaBeginEndSpaceOffset ;

@property (nonatomic)       NSUInteger location ;
@property (nonatomic)       NSUInteger length ;

- (UIFont *)defaultFont ;
- (NSDictionary *)defultStyle ;


// construct
- (instancetype)initWithType:(int)type range:(NSRange)range str:(NSString *)str ;

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str ;

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str level:(int)level ;



// ********* rewrite in subcls ********* //

- (NSString *)displayStringForLeftLabel ;

// RENDER preview state
- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString ;

// RENDER edit state
- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition ;

// ********* rewrite in subcls ********* //

+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range ;

@end

NS_ASSUME_NONNULL_END

