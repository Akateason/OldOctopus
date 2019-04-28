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
- (void)imageSelectedAtNewPosition:(NSInteger)position imageModel:(MdInlineModel *)model ;
- (void)listBlockParsingFinished:(NSArray *)list ;
@end


@interface XTMarkdownParser : NSObject
@property (weak, nonatomic)             id<XTMarkdownParserDelegate>    delegate ;
@property (readonly, strong, nonatomic) MDThemeConfiguration            *configuration ;
@property (readonly, strong, nonatomic) MDImageManager                  *imgManager ;
@property (readonly, copy, nonatomic)   NSArray                         *currentPositionModelList ; // 当前光标位置所对应的model
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

// pick one model in currentPositionModelList.  return the user choosen type First otherwise any model .
- (MarkdownModel *)modelForModelListInlineFirst ;
- (MarkdownModel *)modelForModelListBlockFirst ;
// return a blkModel with any position
- (MarkdownModel *)getBlkModelForCustomPosition:(NSUInteger)position ;


// Returns the para before this position
- (MarkdownModel *)lastParaModelForPosition:(NSUInteger)position ;

// left icon image String
- (NSString *)iconImageStringOfPosition:(NSUInteger)position
                                  model:(MarkdownModel *)model ;

// article infos
- (NSInteger)countForWord ;
- (NSInteger)countForCharactor ;
- (NSInteger)countForPara ;

@end

NS_ASSUME_NONNULL_END
