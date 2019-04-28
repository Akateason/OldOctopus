//
//  XTMarkdownParser.m
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "model/MDHeadModel.h"
#import "model/MdInlineModel.h"
#import "model/MdListModel.h"
#import "model/MdBlockModel.h"
#import "model/MdOtherModel.h"
#import "MarkdownEditor.h"
#import "MDImageManager.h"
#import "XTMarkdownParser+Regular.h"
#import "XTMarkdownParser+ImageUtil.h"
#import "Note.h"

@interface XTMarkdownParser ()
@property (strong, nonatomic)   MDThemeConfiguration        *configuration ;
@property (strong, nonatomic)   MDImageManager              *imgManager ;
@property (copy, nonatomic)     NSArray                     *paraList ; // 所有段落以及段落行内(组合形式)
@property (copy, nonatomic)     NSArray                     *hrList ; // 分割线
@property (strong, nonatomic)   NSMutableAttributedString   *editAttrStr ;
@property (copy, nonatomic)     NSArray                     *currentPositionModelList ; // 当前光标位置所对应的model

@end

@implementation XTMarkdownParser

- (instancetype)initWithConfig:(MDThemeConfiguration *)config {
    self = [super init] ;
    if (self) {
        _configuration  = config ;
        _imgManager     = [MDImageManager new] ;
        _paraList       = @[] ;
        _hrList         = @[] ;
    }
    return self ;
}

#pragma mark - parse

/**
 parse and update attr and get models in current cursor position .
 @param text      clean text
 @param textView  from textview
 @return model list OF CURRENT POSISTION
 */
- (NSArray *)parseTextAndGetModelsInCurrentCursor:(NSString *)text
                                         textView:(UITextView *)textView {
    
    return [self parseTextAndGetModelsInCurrentCursor:text customPosition:-1 textView:textView] ;
}

- (NSArray *)parseTextAndGetModelsInCurrentCursor:(NSString *)text
                                   customPosition:(NSUInteger)positionCus
                                         textView:(UITextView *)textView {
    
    NSUInteger position = (positionCus == -1) ? textView.selectedRange.location : positionCus ;
    __block NSMutableArray *tmpCurrentModelList = [@[] mutableCopy] ;
    __block NSMutableAttributedString *attributedString = [self updateImages:text textView:textView] ;
    self.editAttrStr = attributedString ;
    
    [self parsingModelsForText:attributedString.string] ;
    NSArray *wholeList = [self.paraList arrayByAddingObjectsFromArray:self.hrList] ;
    
    // render attr
    [attributedString beginEditing] ;
    // add default style
    [attributedString addAttributes:self.configuration.editorThemeObj.basicStyle range:NSMakeRange(0, text.length)] ;
    // render every node
    [wholeList enumerateObjectsUsingBlock:^(MarkdownModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *tmpCurrent = [self renderByModel:model textView:textView position:position attr:attributedString] ;
        [tmpCurrentModelList addObjectsFromArray:tmpCurrent] ;
        if (model.inlineModels.count) {
            [model.inlineModels enumerateObjectsUsingBlock:^(MarkdownModel *inlineModels, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *tmpCurrent = [self renderByModel:inlineModels textView:textView position:position attr:attributedString] ;
                [tmpCurrentModelList addObjectsFromArray:tmpCurrent] ;
            }] ;
        }
    }] ;
    [attributedString endEditing] ;
    
    // update
    [self updateAttributedText:attributedString textView:textView] ;
    [self drawQuoteBlk] ;
    [self drawListBlk] ;
    self.currentPositionModelList = tmpCurrentModelList ;
    return tmpCurrentModelList ;
}

- (NSArray *)renderByModel:(MarkdownModel *)model
             textView:(UITextView *)textView
             position:(NSUInteger)position
                 attr:(NSMutableAttributedString *)attributedString {
    
    NSMutableArray *tmpCurrentlist = [@[] mutableCopy] ;
    if ( NSLocationInRange(position, model.range) || position == model.range.location + model.range.length ) {
        model.isOnEditState = YES ;
        [tmpCurrentlist addObject:model] ;
    }
    
    // render any style
    if (!textView.isFirstResponder) {
        attributedString = [model addAttrOnPreviewState:attributedString] ;
    }
    else {
        attributedString = (!model.isOnEditState) ?
        [model addAttrOnPreviewState:attributedString] :
        [model addAttrOnEditState:attributedString position:textView.selectedRange.location] ;
    }
    
    return tmpCurrentlist ;
}

- (void)parsingModelsForText:(NSString *)text {
    
    NSMutableArray *paralist = [@[] mutableCopy] ;
    // parse for paragraphs, get outside paras
    NSRegularExpression *expPara = regexp(MDPR_paragraph, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsPara = [expPara matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsPara) {
        MarkdownModel *model = [MarkdownModel modelWithType:-1 range:result.range str:[text substringWithRange:result.range]] ;
        [paralist addObject:model] ;
    }
    
    NSMutableArray *tmplist = [paralist mutableCopy] ;
    
    // parsing get block list first . if is block then parse for inline attr , if not a block parse this para's inline attr .
    [paralist enumerateObjectsUsingBlock:^(MarkdownModel *pModel, NSUInteger idx, BOOL * _Nonnull stop) {
        // judge is block
        MarkdownModel *resModel = [self parsingGetABlockStyleModelFromParaModel:pModel] ;
        if (resModel != nil) {
            // model is block style
            // parsing get inline model
            NSArray *resInlineListFromBlock = [self parsingModelForInlineStyleWithOneParagraphModel:resModel] ;
            resModel.inlineModels = resInlineListFromBlock ;
            [tmplist replaceObjectAtIndex:idx withObject:resModel] ;
        }
        else {
            // is not block style
            // inline parsing
            NSArray *resInlineListFromParagraph = [self parsingModelForInlineStyleWithOneParagraphModel:pModel] ;
            pModel.inlineModels = resInlineListFromParagraph ;
            [tmplist replaceObjectAtIndex:idx withObject:pModel] ;
        }
    }] ;
    self.paraList = tmplist ; // get all para and inlines .
    paralist = nil ;
    
    // parse for hr
    NSMutableArray *tmpHrlist = [@[] mutableCopy] ;
    NSRegularExpression *expHr = regexp(MDPR_hr, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsHr = [expHr matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsHr) {
        MdOtherModel *model = [MdOtherModel modelWithType:MarkdownSyntaxHr range:result.range str:[text substringWithRange:result.range]] ;
        [tmpHrlist addObject:model] ;
    }
    self.hrList = tmpHrlist ;
}

- (id)parsingGetABlockStyleModelFromParaModel:(MarkdownModel *)pModel {
    
    for (MarkdownSyntaxType i = NumberOfMarkdownSyntax - 1; i > 0 ; i--) {
        NSRegularExpression *expression = [self getRegularExpressionFromMarkdownSyntaxType:i] ;
        NSArray *matches = [expression matchesInString:pModel.str options:0 range:NSMakeRange(0, [pModel.str length])] ;
        for (NSTextCheckingResult *result in matches) {
            NSRange tmpRange = NSMakeRange(pModel.range.location + result.range.location, result.range.length) ;
            // model is block model
            switch (i) {
                case MarkdownSyntaxUnknown: break ;
                    
                case MarkdownSyntaxHeaders: {
                    return [MDHeadModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range]] ;
                }
                    
                case MarkdownSyntaxTaskLists:
                case MarkdownSyntaxOLLists:
                case MarkdownSyntaxULLists: {
                    return [MdListModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range]] ;
                }
                    
                case MarkdownSyntaxBlockquotes:
                case MarkdownSyntaxCodeBlock: {
                    return [MdBlockModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range]] ;
                }
                    
                case MarkdownSyntaxMultipleMath:
                case MarkdownSyntaxNpTable:
                case MarkdownSyntaxTable: {
                    return [MdOtherModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range]] ;
                }
                    
                case NumberOfMarkdownSyntax: break ;
            }
        }
    }
    
    return nil ;
}

- (NSArray *)parsingModelForInlineStyleWithOneParagraphModel:(MarkdownModel *)paraModel {
    
    NSMutableArray *escapeList = [@[] mutableCopy] ;
    NSRegularExpression *escapeExpression = regexp(MDIL_ESCAPE , 0) ;
    NSArray *escapeMatches = [escapeExpression matchesInString:paraModel.str options:0 range:NSMakeRange(0, [paraModel.str length])] ;
    for (NSTextCheckingResult *esResult in escapeMatches) {
        NSRange tmpRange = NSMakeRange(paraModel.range.location + esResult.range.location, esResult.range.length) ;
        MarkdownModel *resModel = [MdInlineModel modelWithType:MarkdownInlineEscape range:tmpRange str:[paraModel.str substringWithRange:esResult.range]] ;
        [escapeList addObject:resModel] ;
    }
    
    NSMutableArray *tmpInlineList = [@[] mutableCopy] ;
    for (MarkdownInlineType i = MarkdownInlineUnknown; i < NumberOfMarkdownInline ; i++) {
        NSRegularExpression *expression = [self getRegularExpressionFromMarkdownInlineType:i] ;
        NSArray *matches = [expression matchesInString:paraModel.str options:0 range:NSMakeRange(0, [paraModel.str length])] ;
        
        for (NSTextCheckingResult *result in matches) {
            if (paraModel.type == MarkdownSyntaxCodeBlock  && i == MarkdownInlineInlineCode) {
                // 段落代码块 和 行内代码 不兼容.
                continue ;
            }
            
            if (i == MarkdownInlineLinks) {
                // 链接 和 图片
                NSString *prefixCha = [[paraModel.str substringWithRange:result.range] substringWithRange:NSMakeRange(0, 1)] ;
                if ([prefixCha isEqualToString:@"!"]) {
                    NSRange tmpRange = NSMakeRange(paraModel.range.location + result.range.location, result.range.length) ;
                    MarkdownModel *resModel = [MdInlineModel modelWithType:MarkdownInlineImage range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
                    [tmpInlineList addObject:resModel] ;
                }
                else {
                    NSRange tmpRange = NSMakeRange(paraModel.range.location + result.range.location, result.range.length) ;
                    MarkdownModel *resModel = [MdInlineModel modelWithType:MarkdownInlineLinks range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
                    [tmpInlineList addObject:resModel] ;
                }
                
                continue ;
            }
            
            NSRange tmpRange = NSMakeRange(paraModel.range.location + result.range.location, result.range.length) ;
            MarkdownModel *resModel = [MdInlineModel modelWithType:i range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
            
            BOOL containEscape = NO ; // 转义字符
            for (MdInlineModel *escapeMod in escapeList) {
                NSRange intersectionRange = NSIntersectionRange(escapeMod.range,resModel.range) ;
                if (intersectionRange.length > 0 && i != MarkdownInlineEscape) {
                    containEscape = YES ;
                    break ;
                }
            }
            
            if (!containEscape) [tmpInlineList addObject:resModel] ;
        }
    }
    
    return tmpInlineList ;
}

#pragma mark - update attr text in text view

- (void)updateAttributedText:(NSAttributedString *)attributedString
                    textView:(UITextView *)textView {
    
    textView.scrollEnabled = NO ;
    NSRange selectedRange = textView.selectedRange ;
    textView.text = attributedString.string ;
    textView.attributedText = attributedString ;
    
    textView.selectedRange = selectedRange ;
    textView.scrollEnabled = YES ;
    self.editAttrStr = [attributedString mutableCopy] ;
}

#pragma mark - return current model with position

- (MarkdownModel *)modelForModelListInlineFirst {
    MarkdownModel *tmpModel = nil ;
    NSArray *modellist = self.currentPositionModelList ;
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type > MarkdownInlineUnknown) {
            return tmpModel ;
        }
    }
    return tmpModel ;
}

- (MarkdownModel *)modelForModelListBlockFirst {
    MarkdownModel *tmpModel = nil ;
    NSArray *modellist = self.currentPositionModelList ;
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type < MarkdownInlineUnknown) {
            return tmpModel ;
        }
    }
    return tmpModel ;
}

- (MarkdownModel *)getBlkModelForCustomPosition:(NSUInteger)position {
    NSArray *list = self.paraList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            if (model.type < MarkdownInlineUnknown) {
                return model ; // return blkModel
            }
        }
    }
    return nil ;
}

// Returns the para before this position's para
- (MarkdownModel *)lastParaModelForPosition:(NSUInteger)position {
    id lastModel = nil ;
    for (int i = 0; i < self.paraList.count; i++) {
        MarkdownModel *model = self.paraList[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        if (isInRange) {
            return lastModel ;
        }
        else {
            if (i > 0) {
                MarkdownModel *sygModel = self.paraList[i - 1] ;
                if (position > sygModel.range.location + sygModel.range.length &&
                    position < model.range.location) {
                    return sygModel ;
                }
            }
        }
        lastModel = model ;
    }
    return nil ;
}




#pragma mark - call draw native views .

- (void)drawQuoteBlk {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [self.paraList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.type == MarkdownSyntaxBlockquotes) {
            [tmplist addObject:model] ;
        }
    }] ;
    if (self.delegate) [self.delegate quoteBlockParsingFinished:tmplist] ;
}

- (void)drawListBlk {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [self.paraList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists || model.type == MarkdownSyntaxTaskLists) {
            [tmplist addObject:model] ;
        }
    }] ;
    if (self.delegate) [self.delegate listBlockParsingFinished:tmplist] ;
}

- (NSString *)iconImageStringOfPosition:(NSUInteger)position
                                  model:(MarkdownModel *)model {
    
    if (model.type == MarkdownSyntaxHeaders) {
        // header
        if (!position) position++ ;
        
        NSString *lastString = [self.editAttrStr.string substringWithRange:NSMakeRange(position - 1, 1)] ;
        if ([lastString isEqualToString:@"\n"]) {
            return @"" ;
        }
    }
    return [model displayStringForLeftLabel] ;
}




#pragma mark - article infos

- (NSInteger)countForWord {
    return [Note filterMarkdownString:self.editAttrStr.string].length ;
}

- (NSInteger)countForCharactor {
    return self.editAttrStr.string.length ;
}

- (NSInteger)countForPara {
    return self.paraList.count ;
}



@end
