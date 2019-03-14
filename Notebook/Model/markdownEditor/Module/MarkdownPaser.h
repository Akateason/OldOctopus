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
#import "MarkdownModel.h"
@class MDThemeConfiguration ;

NS_ASSUME_NONNULL_BEGIN
@interface MarkdownPaser : NSObject
@property (readonly, strong, nonatomic) MDThemeConfiguration *configuration;
- (instancetype)initWithConfig:(MDThemeConfiguration *)config ;

#pragma mark -

//- (NSAttributedString *)parseText:(NSString *)text ;
- (NSAttributedString *)parseText:(NSString *)text
                         position:(NSUInteger)position ;

- (MarkdownModel *)modelForRangePosition:(NSUInteger)position ;
- (NSArray *)modelListForRangePosition:(NSUInteger)position ;

- (NSString *)stringTitleOfPosition:(NSUInteger)position ;
- (NSString *)stringTitleOfPosition:(NSUInteger)position
                              model:(MarkdownModel *)model ;

@end

NS_ASSUME_NONNULL_END
