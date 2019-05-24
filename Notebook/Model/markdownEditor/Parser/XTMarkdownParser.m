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
#import "XTMarkdownParser+ImageUtil.h"
#import "XTMarkdownParser+Regular.h"
#import "XTMarkdownParser+ImageUtil.h"
#import "Note.h"

@interface XTMarkdownParser ()
@property (strong, nonatomic)   MDThemeConfiguration        *configuration ;
@property (strong, nonatomic)   MDImageManager              *imgManager ;
@property (copy, nonatomic)     NSArray                     *paraList ;                 // 所有段落以及段落行内(组合形式)
@property (copy, nonatomic)     NSArray                     *hrList ;                   // 分割线
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
    
    [[textView.undoManager prepareWithInvocationTarget:self] parseTextAndGetModelsInCurrentCursor:text customPosition:positionCus textView:textView] ;
    [textView.undoManager setActionName:NSLocalizedString(@"actions.editor-parse", @"parse text")] ;

    
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
    // render every blk or para node
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
//    [self drawCodeBlk] ;
    [self drawInlineCode] ;
    [self drawHr] ;
    self.currentPositionModelList = tmpCurrentModelList ;
    if (positionCus != -1 && textView.selectedRange.length == 0) {
        textView.selectedRange = NSMakeRange(positionCus, 0) ;
    }
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
    
    if (model.subBlkModel != nil) {
        [self renderByModel:model.subBlkModel textView:textView position:position attr:attributedString] ;
    }
    
    return tmpCurrentlist ;
}

- (void)parsingModelsForText:(NSString *)text {
    
    //1. parse code blk
    NSMutableArray *codeBlkList = [@[] mutableCopy] ;
    NSRegularExpression *expCb = regexp(MDPR_codeBlock, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsCb = [expCb matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsCb) {
        MdBlockModel *model = [MdBlockModel modelWithType:MarkdownSyntaxCodeBlock range:result.range str:[text substringWithRange:result.range]] ;
        [codeBlkList addObject:model] ;
    }
    
    
    //2. parse for paragraphs, get outside paras
    NSMutableArray *paralist = [@[] mutableCopy] ;
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
                             options:NSStringEnumerationByParagraphs
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              MarkdownModel *model = [MarkdownModel modelWithType:-1 range:substringRange str:substring] ;
                              if (model.str.length) [paralist addObject:model] ;
                          }] ;    
    
    //3. parsing get block list first . replace codeBlock First. if is block then parse for inline attr , if not a block parse this para's inline attr .
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    
    [paralist enumerateObjectsUsingBlock:^(MarkdownModel *pModel, NSUInteger idx, BOOL * _Nonnull stop) {
        MarkdownModel *resModel = [self parsingGetABlockStyleModelFromParaModel:pModel] ;
        //4.1 exchange codeblk model for paraModel
        BOOL isCodeBlk = NO ;
        for (MarkdownModel *cbModel in codeBlkList) {
            if ( pModel.location >= cbModel.location && pModel.location + pModel.length <= cbModel.location + cbModel.length ) {
                [tmplist addObject:cbModel] ;
                isCodeBlk = YES ;
                break ;
            }
        }
        if (isCodeBlk) return ; // continue
        
        
        //4.2 judge is block Style .
        if (resModel) {
            //4.2.1 model is block style , parsing get inline model
            NSArray *resInlineListFromBlock = [self parsingModelForInlineStyleWithOneParagraphModel:resModel] ;
            resModel.inlineModels = resInlineListFromBlock ;
            [tmplist addObject:resModel] ;
        }
        else {
            //4.2.2 is not block style , inline parsing
            NSArray *resInlineListFromParagraph = [self parsingModelForInlineStyleWithOneParagraphModel:pModel] ;
            pModel.inlineModels = resInlineListFromParagraph ;
            [tmplist addObject:pModel] ;
        }
    }] ;
    
    paralist = tmplist ;
    
    self.paraList = tmplist ; // get all para and inlines .
    paralist = nil ;
    tmplist = nil ;
    
    [self optParaListThenWrapInParaBeginEnd] ;
    
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

- (void)optParaListThenWrapInParaBeginEnd {
    NSMutableArray *list = [self.paraList mutableCopy] ;
    
    for (int i = 0; i < self.paraList.count; i++) {
        MarkdownModel *model = self.paraList[i] ;
        if (model.type == MarkdownSyntaxHeaders) {
            if (i >= 1) {
                MarkdownModel *lastModel = self.paraList[i - 1] ;
                lastModel.paraBeginEndSpaceOffset = 2 ;
                [list replaceObjectAtIndex:i - 1 withObject:lastModel] ;
            }
            
            if (self.paraList.count - 1 > i) {
                MarkdownModel *nextModel = self.paraList[i + 1] ;
                model.paraBeginEndSpaceOffset = nextModel.type == MarkdownSyntaxHeaders ? 2 : 1 ;
                [list replaceObjectAtIndex:i withObject:model] ;
            }
        }
    }
    
    self.paraList = list ;
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
                    return [MDHeadModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range] level:pModel.quoteAndList_Level] ;
                }
                    
                case MarkdownSyntaxTaskLists:
                case MarkdownSyntaxOLLists:
                case MarkdownSyntaxULLists: {
                    return [MdListModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range] level:pModel.quoteAndList_Level] ;
                }
                    
                case MarkdownSyntaxBlockquotes: {
                    return [MdBlockModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range] level:pModel.quoteAndList_Level] ;
                }
                    
                case MarkdownSyntaxMultipleMath:
                case MarkdownSyntaxNpTable:
                case MarkdownSyntaxTable: {
                    return [MdOtherModel modelWithType:i range:tmpRange str:[pModel.str substringWithRange:result.range] level:pModel.quoteAndList_Level] ;
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
        MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineEscape range:tmpRange str:[paraModel.str substringWithRange:esResult.range]] ;
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
                    MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineImage range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
                    [tmpInlineList addObject:resModel] ;
                }
                else {
                    NSRange tmpRange = NSMakeRange(paraModel.range.location + result.range.location, result.range.length) ;
                    MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineLinks range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
                    [tmpInlineList addObject:resModel] ;
                }
                
                continue ;
            }
            
            NSRange tmpRange = NSMakeRange(paraModel.range.location + result.range.location, result.range.length) ;
            MdInlineModel *resModel = [MdInlineModel modelWithType:i range:tmpRange str:[paraModel.str substringWithRange:result.range]] ;
            
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

#pragma mark - call draw native views .

- (void)drawQuoteBlk {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [self.paraList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.type == MarkdownSyntaxBlockquotes) {
            [tmplist addObject:model] ;
        }
        
        while ( (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists || model.type == MarkdownSyntaxTaskLists ||
                 model.type == MarkdownSyntaxBlockquotes)
                &&
               (model.subBlkModel) ) {
            
            if (model.subBlkModel.type == MarkdownSyntaxBlockquotes) [tmplist addObject:model.subBlkModel] ;
            
            model = model.subBlkModel ;
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
        
        while ( (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists || model.type == MarkdownSyntaxTaskLists ||
                 model.type == MarkdownSyntaxBlockquotes)
                &&
                (model.subBlkModel) ) {
            
            if (model.subBlkModel.type == MarkdownSyntaxOLLists || model.subBlkModel.type == MarkdownSyntaxULLists) [tmplist addObject:model.subBlkModel] ;
            
            model = model.subBlkModel ;
        }
    }] ;
    if (self.delegate) [self.delegate listBlockParsingFinished:tmplist] ;
}

//- (void)drawCodeBlk {
//    NSMutableArray *tmplist = [@[] mutableCopy] ;
//    [self.paraList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (model.type == MarkdownSyntaxCodeBlock) {
//            [tmplist addObject:model] ;
//        }
//    }] ;
////    if (self.delegate) [self.delegate codeBlockParsingFinished:tmplist] ;
//}

- (void)drawInlineCode {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [self.paraList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [model.inlineModels enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull inlineModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (inlineModel.type == MarkdownInlineInlineCode) {
                [tmplist addObject:inlineModel] ;
            }
        }] ;
    }] ;
    if (self.delegate) [self.delegate inlineCodeParsingFinished:tmplist] ;
}

- (void)drawHr {
    if (self.delegate) [self.delegate hrParsingFinished:self.hrList] ;
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
