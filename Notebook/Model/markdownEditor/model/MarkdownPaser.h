//
//  MarkdownPaser.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MarkdownSyntaxType){
    MarkdownSyntaxUnknown,
    
    MarkdownSyntaxNewLine, // 换行
    
    // 标题
    MarkdownSyntaxHeaders,
    
    // 行内样式
    MarkdownSyntaxBold, // 粗体
    MarkdownSyntaxItalic, // 斜体
    MarkdownSyntaxBoldItalic, // 粗体+斜体
    MarkdownSyntaxDeletions, // 删除线
    MarkdownSyntaxInlineCode, // 行内代码
    
    
    
    MarkdownSyntaxLinks, // 链接
    MarkdownSyntaxQuotes,
    MarkdownSyntaxCodeBlock,
    MarkdownSyntaxBlockquotes,
    MarkdownSyntaxULLists,
    MarkdownSyntaxOLLists,
    
    
    NumberOfMarkdownSyntax
};



@class MarkdownPaser ;

@interface MarkdownModel : NSObject

@property (nonatomic) NSRange range ; // 绝对定位 range
@property (nonatomic) MarkdownSyntaxType type ;
@property (copy, nonatomic) NSString *str ;

- (instancetype)initWithType:(MarkdownSyntaxType)type
                       range:(NSRange)range
                         str:(NSString *)str ;

+ (instancetype)modelWithType:(MarkdownSyntaxType)type
                        range:(NSRange)range
                          str:(NSString *)str ;
@end








@interface MarkdownPaser : NSObject
@property (copy, nonatomic) NSArray *currentPaserResultList ;



#pragma mark -
- (NSAttributedString *)parseText:(NSString *)text ;
- (MarkdownModel *)modelForRangePosition:(NSUInteger)position ;
+ (NSString *)stringTitleOfModel:(MarkdownModel *)model ;
@end

NS_ASSUME_NONNULL_END
