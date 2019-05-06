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

@property (nonatomic)           int             quoteLevel ; // 层级中有几个引用(或者引用中的列表),控制引用的text缩进
@property (nonatomic)           int             nestLevel ;
@property (strong, nonatomic)   MarkdownModel   *subBlkModel ;


- (NSUInteger)location ;
- (NSUInteger)length ;
- (UIFont *)defaultFont ;
- (NSDictionary *)defultStyle ;


// construct
- (instancetype)initWithType:(int)type
                       range:(NSRange)range
                         str:(NSString *)str ;

+ (instancetype)modelWithType:(int)type
                        range:(NSRange)range
                          str:(NSString *)str ;


// ********* rewrite in subcls ********* //

- (NSString *)displayStringForLeftLabel ;

// RENDER preview state
- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString ;

// RENDER edit state
- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition ;

// ********* rewrite in subcls ********* //

@end

NS_ASSUME_NONNULL_END
