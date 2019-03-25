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
@class MDThemeConfiguration,MarkdownPaser ;

NS_ASSUME_NONNULL_BEGIN

@protocol MarkdownParserDelegate <NSObject>
@required
- (void)quoteBlockParsingFinished:(NSArray *)list ;
- (void)imageSelectedAtNewPosition:(NSInteger)position ;
- (void)listBlockParsingFinished:(NSArray *)list ;
@end



@interface MarkdownPaser : NSObject
@property (weak, nonatomic)             id<MarkdownParserDelegate>  delegate ;
@property (readonly, strong, nonatomic) MDThemeConfiguration        *configuration ;
- (instancetype)initWithConfig:(MDThemeConfiguration *)config ;

#pragma mark -

- (NSMutableAttributedString *)readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:(NSString *)text
                                                                                 textView:(UITextView *)textView ;

- (void)parseText:(NSString *)text
         position:(NSUInteger)position
         textView:(UITextView *)textView ;

- (void)updateAttributedText:(NSAttributedString *)attributedString
                    textView:(UITextView *)textView ;

- (MarkdownModel *)modelForRangePosition:(NSUInteger)position ;
- (NSArray *)modelListForRangePosition:(NSUInteger)position ;

- (MarkdownModel *)paraModelForPosition:(NSUInteger)position ;
- (MarkdownModel *)blkModelForRangePosition:(NSUInteger)position ;

- (NSString *)stringTitleOfPosition:(NSUInteger)position ;
- (NSString *)stringTitleOfPosition:(NSUInteger)position
                              model:(MarkdownModel *)model ;




@end

NS_ASSUME_NONNULL_END
