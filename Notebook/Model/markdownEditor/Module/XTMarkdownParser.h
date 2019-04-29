//
//  XTMarkdownParser.h
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MdParserRegexpHeader.h"
#import "MarkdownModel.h"

@class MDThemeConfiguration,MarkdownPaser,MDImageManager,MdInlineModel ;


NS_ASSUME_NONNULL_BEGIN

@protocol XTMarkdownParserDelegate <NSObject>
@required
- (void)quoteBlockParsingFinished:(NSArray *)list ;
- (void)listBlockParsingFinished:(NSArray *)list ;
- (NSRange)currentCursorRange ;
@end


@interface XTMarkdownParser : NSObject
@property (weak, nonatomic)             id<XTMarkdownParserDelegate>    delegate ;
@property (readonly, strong, nonatomic) MDThemeConfiguration            *configuration ;
@property (readonly, strong, nonatomic) NSMutableAttributedString       *editAttrStr ;
@property (readonly, copy, nonatomic)   NSArray                         *paraList ;
@property (readonly, copy, nonatomic)   NSArray                         *currentPositionModelList ; // 当前光标位置所对应的model
@property (readonly, strong, nonatomic) MDImageManager                  *imgManager ;
- (instancetype)initWithConfig:(MDThemeConfiguration *)config ;


/**
 parse and update attr and get models in current cursor position .
 @param text      clean text
 @param textView  from textview
 @return model list OF CURRENT POSISTION
 */
- (NSArray *)parseTextAndGetModelsInCurrentCursor:(NSString *)text
                                         textView:(UITextView *)textView ;
- (NSArray *)parseTextAndGetModelsInCurrentCursor:(NSString *)text
                                   customPosition:(NSUInteger)positionCus
                                         textView:(UITextView *)textView ;
// update attr text in textView
- (void)updateAttributedText:(NSAttributedString *)attributedString
                    textView:(UITextView *)textView ;



// article infos
- (NSInteger)countForWord ;
- (NSInteger)countForCharactor ;
- (NSInteger)countForPara ;

// draw native
- (void)drawQuoteBlk ;
- (void)drawListBlk ;

@end

NS_ASSUME_NONNULL_END
