//
//  MarkdownPaser.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MdParserRegexpHeader.h"



NS_ASSUME_NONNULL_BEGIN


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
