//
//  MarkdownPaser.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownPaser.h"
#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "model/MDHeadModel.h"
#import "model/MdInlineModel.h"
#import "model/MdListModel.h"
#import "model/MdBlockModel.h"
#import "model/MdOtherModel.h"


@interface MarkdownPaser ()
@property (strong, nonatomic) MDThemeConfiguration *configuration;

@property (copy, nonatomic) NSArray *modelList ;
@property (copy, nonatomic) NSString *originalText ;
@end

@implementation MarkdownPaser

- (instancetype)initWithConfig:(MDThemeConfiguration *)config {
    self = [super init];
    if (self) {
        _configuration = config ;
        _modelList = @[] ;
    }
    return self;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type {
    switch (type) {
        case MarkdownSyntaxUnknown: break;
            
        case MarkdownSyntaxHeaders:
            return regexp(MDPR_heading, NSRegularExpressionAnchorsMatchLines) ;
//        case MarkdownSyntaxLHeader:
//            return regexp(MDPR_lheading, NSRegularExpressionAnchorsMatchLines) ;
        
        case MarkdownSyntaxTaskLists:
            return regexp(MDPR_tasklist, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxOLLists:
            return regexp(MDPR_orderlist, NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxULLists:
            return regexp(MDPR_bulletlist, NSRegularExpressionAnchorsMatchLines);
            
        case MarkdownSyntaxBlockquotes:
            return regexp(MDPR_blockquote,NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxCodeBlock:
            return regexp(MDPR_codeBlock,NSRegularExpressionAnchorsMatchLines);
        
        case MarkdownSyntaxHr:
            return regexp(MDPR_hr, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxMultipleMath:
            return regexp(MDPR_multiplemath, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxNpTable:
            return regexp(MDPR_NpTable, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxTable :
            return regexp(MDPR_table, NSRegularExpressionAnchorsMatchLines) ;
            
        case NumberOfMarkdownSyntax: break ;
    }
    return nil;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownInlineType:(MarkdownInlineType)type {
    switch (type) {
        case MarkdownInlineUnknown: break ;
            
        case MarkdownInlineBold:
            return regexp(MDIL_BOLD, 0);
        case MarkdownInlineItalic:
            return regexp(MDIL_ITALIC, 0);
        case MarkdownInlineBoldItalic:
            return regexp(MDIL_BOLDITALIC, 0);
        case MarkdownInlineDeletions:
            return regexp(MDIL_DELETION, 0);
        case MarkdownInlineInlineCode:
            return regexp(MDIL_INLINECODE, 0);
        case MarkdownInlineLinks:
            return regexp(MDIL_LINKS, 0);
        
        default: break;
    }
    return nil;
}

- (NSArray *)parsingModelsForText:(NSString *)text {
    NSMutableArray *resultModelList = [@[] mutableCopy] ;
    
    NSMutableArray *paralist = [@[] mutableCopy] ;
    // parse for paragraphs
    NSRegularExpression *expPara = regexp(MDPR_paragraph, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsPara = [expPara matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsPara) {
        MarkdownModel *model = [MarkdownModel modelWithType:-1
                                                      range:result.range
                                                        str:[text substringWithRange:result.range]] ;
        [paralist addObject:model] ;
    }
    
    // parsing get block list first . if is block then parse for inline attr , if not a block parse this para's inline attr .
    [paralist enumerateObjectsUsingBlock:^(MarkdownModel *pModel, NSUInteger idx, BOOL * _Nonnull stop) {
        // judge is block
        id resModel = [self parsingGetABlockStyleModelFromParaModel:pModel] ;
        if (resModel != nil) {
            // is block style
            [resultModelList addObject:resModel] ;
            // inline parsing
            NSArray *resInlineListFromBlock = [self parsingModelForInlineStyleWithOneParagraphModel:resModel] ;
            [resultModelList addObjectsFromArray:resInlineListFromBlock] ;
        }
        else {
            // is not block style
            // inline parsing
            NSArray *resInlineListFromParagraph = [self parsingModelForInlineStyleWithOneParagraphModel:pModel] ;
            [resultModelList addObjectsFromArray:resInlineListFromParagraph] ;
        }
    }] ;
    
    // parse for hr
    NSRegularExpression *expHr = regexp(MDPR_hr, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsHr = [expHr matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsHr) {
        MdOtherModel *model = [MdOtherModel modelWithType:MarkdownSyntaxHr range:result.range str:[text substringWithRange:result.range]] ;
        [resultModelList addObject:model] ;
    }
    
    return resultModelList ;
//    return paralist ;
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
    NSMutableArray *tmpInlineList = [@[] mutableCopy] ;

    for (MarkdownInlineType i = MarkdownInlineUnknown; i < NumberOfMarkdownInline ; i++) {
        NSRegularExpression *expression = [self getRegularExpressionFromMarkdownInlineType:i] ;
        NSArray *matches = [expression matchesInString:paraModel.str options:0 range:NSMakeRange(0, [paraModel.str length])] ;
        
        for (NSTextCheckingResult *result in matches) {
            if (paraModel.type == MarkdownSyntaxCodeBlock  && i == MarkdownInlineInlineCode) {
                // 段落代码块 和 行内代码 不兼容.
                continue ;
            }
            
            NSRange tmpRange = NSMakeRange(paraModel.range.location + result.range.location, result.range.length) ;
            MarkdownModel *resModel = [MdInlineModel modelWithType:i range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
            [tmpInlineList addObject:resModel] ;
        }
    }
    
    return tmpInlineList ;
}


- (MarkdownModel *)modelForRangePosition:(NSUInteger)position {
    NSArray *list = self.modelList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            return model ;
        }
    }
    return nil ;
}

- (NSArray *)modelListForRangePosition:(NSUInteger)position {
    NSArray *list = self.modelList ;
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            [tmplist addObject:model] ;
        }
    }
    return tmplist ;
}

- (NSString *)stringTitleOfPosition:(NSUInteger)position {
    MarkdownModel *model = [self modelForRangePosition:position] ;
    return [self stringTitleOfPosition:position model:model] ;
}

- (NSString *)stringTitleOfPosition:(NSUInteger)position model:(MarkdownModel *)model {
    if (model.type == MarkdownSyntaxHeaders) {
        // header
        if (!position) position++ ;
        
        NSString *lastString = [self.originalText substringWithRange:NSMakeRange(position - 1, 1)] ;
        if ([lastString isEqualToString:@"\n"]) {
            return @"" ;
        }
    }
    return [model displayStringForLeftLabel] ;
}

- (void)setModelList:(NSArray *)modelList {
    _modelList = modelList ;
    
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [modelList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.type == MarkdownSyntaxBlockquotes) {
            [tmplist addObject:model] ;
        }
    }] ;
    
    if (self.delegate) [self.delegate quoteBlockParsingFinished:tmplist] ;
}


/**
 parse / update attr .

 @param text \
 @param position  for model state .
 */
- (NSAttributedString *)parseText:(NSString *)text
                         position:(NSUInteger)position {
    
    self.originalText = text ;
    NSArray *tmpModelList = [self parsingModelsForText:text] ; // get model list, all in preview state at first .
    __block NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text] ;
    
    [attributedString beginEditing] ;
    [attributedString addAttributes:self.configuration.basicStyle range:NSMakeRange(0, text.length)] ; // add default style
    
    [tmpModelList enumerateObjectsUsingBlock:^(MarkdownModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (NSLocationInRange(position, model.range)) {
            model.isOnEditState = YES ;
        }
        
        // judge bullet
        if (model.type == MarkdownSyntaxULLists) {
            [attributedString replaceCharactersInRange:NSMakeRange(model.range.location, 1) withString:kMark_Bullet] ;
        }
        
        // render any style
        if (!model.isOnEditState) {
            attributedString = [model addAttrOnPreviewState:attributedString config:self.configuration] ;
        }
        else {
            attributedString = [model addAttrOnEditState:attributedString config:self.configuration] ;
        }
    }] ;
    
    [attributedString endEditing] ;
    self.modelList = tmpModelList ;
    
    return attributedString ;
}

@end
