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
#import "MarkdownEditor.h"
#import "MDImageManager.h"

@interface MarkdownPaser ()
@property (strong, nonatomic) MDThemeConfiguration *configuration ;
@property (strong, nonatomic) MDImageManager *imgManager ;

@property (copy, nonatomic) NSArray *paraList ;
@property (copy, nonatomic) NSArray *modelList ;
@property (strong, nonatomic) NSMutableAttributedString *editAttrStr ;

@property (copy, nonatomic) NSArray *currentPositionModelList ;

@end

@implementation MarkdownPaser

- (instancetype)initWithConfig:(MDThemeConfiguration *)config {
    self = [super init];
    if (self) {
        _configuration = config ;
        _modelList = @[] ;
        _imgManager = [MDImageManager new] ;
    }
    return self;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type {
    switch (type) {
        case MarkdownSyntaxUnknown: break;
            
        case MarkdownSyntaxHeaders:
            return regexp(MDPR_heading, NSRegularExpressionAnchorsMatchLines) ;
        
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
        case MarkdownInlineEscape:
            return regexp(MDIL_ESCAPE , 0);
        
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
    self.paraList = paralist ;
    
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

- (MarkdownModel *)modelForRangePosition:(NSUInteger)position {
    if (position < 1) return nil ;
    
    NSString *strSelect = [self.editAttrStr.string substringWithRange:NSMakeRange(position - 1, 1)] ;
    if ([strSelect isEqualToString:@"\uFFFC"]) {
        MarkdownModel *model = [self modelForRangePosition:position - 3] ; //移动到![]()后面
        if (self.delegate) [self.delegate imageSelectedAtNewPosition:model.range.location imageModel:(MdInlineModel *)model] ; // 图片选择
        return model ;
    }

    id blockModel ;
    NSArray *list = self.modelList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            if (model.type > MarkdownInlineUnknown) {
                return model ; // 优先 行内
            }
            blockModel = model ;
        }
    }
    
    return blockModel ;
}

- (MarkdownModel *)inlineModelForRangePosition:(NSUInteger)position {
    NSArray *list = self.modelList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            if (model.type > MarkdownInlineUnknown) {
                return model ; // 优先 行内
            }
        }
    }
    return nil ;
}

- (MarkdownModel *)blkModelForRangePosition:(NSUInteger)position {
    NSArray *list = self.modelList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
        
        if (isInRange) {
            if (model.type < MarkdownInlineUnknown) {
                return model ; // 优先 块
            }
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

- (MarkdownModel *)paraModelForPosition:(NSUInteger)position {
        
    for (int i = 0; i < self.paraList.count; i++) {
        MarkdownModel *model = self.paraList[i] ;
        BOOL isInRange = (position >= model.range.location) && (position <= model.range.location + model.range.length) ;
        if (isInRange) {
            return model ;
        }
    }
    return nil ;
}

// 返回此p之前的那个para
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



- (NSString *)stringTitleOfPosition:(NSUInteger)position model:(MarkdownModel *)model {
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

- (void)drawQuoteBlk {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [self.modelList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.type == MarkdownSyntaxBlockquotes) {
            [tmplist addObject:model] ;
        }
    }] ;
    if (self.delegate) [self.delegate quoteBlockParsingFinished:tmplist] ;
}

- (void)drawListBlk {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [self.modelList enumerateObjectsUsingBlock:^(MarkdownModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists || model.type == MarkdownSyntaxTaskLists) {
            [tmplist addObject:model] ;
        }
    }] ;
    if (self.delegate) [self.delegate listBlockParsingFinished:tmplist] ;
}

/**
 parse and update attr .

 @param text .      clean text
 @param position    pos for model state .
 */
- (NSArray *)parseText:(NSString *)text
              position:(NSUInteger)position
              textView:(UITextView *)textView {
    
    __block NSMutableArray *tmpCurrentModelList = [@[] mutableCopy] ;
    __block NSMutableAttributedString *attributedString = [self updateImages:text textView:textView] ;
    self.editAttrStr = attributedString ;
    NSArray *tmpModelList = [self parsingModelsForText:attributedString.string] ;
    
    self.modelList = tmpModelList ;
    
    // render attr
    [attributedString beginEditing] ;
    // add default style
    [attributedString addAttributes:self.configuration.editorThemeObj.basicStyle range:NSMakeRange(0, text.length)] ;
    // render every node
    [tmpModelList enumerateObjectsUsingBlock:^(MarkdownModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (NSLocationInRange(position, model.range) || position == model.range.location + model.range.length ) {
            model.isOnEditState = YES ;
            [tmpCurrentModelList addObject:model] ;
        }
        
        // render any style
        if (!textView.isFirstResponder) {
            attributedString = [model addAttrOnPreviewState:attributedString config:self.configuration] ;
        }
        else {
            attributedString = (!model.isOnEditState) ?
            [model addAttrOnPreviewState:attributedString config:self.configuration] :
            [model addAttrOnEditState:attributedString config:self.configuration] ;
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

- (MarkdownModel *)modelForModelListInlineFirst:(NSArray *)modellist {
    MarkdownModel *tmpModel = nil ;
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type > MarkdownInlineUnknown) {
            return tmpModel ;
        }
    }
    return tmpModel ;
}

- (MarkdownModel *)modelForModelListBlockFirst:(NSArray *)modellist {
    MarkdownModel *tmpModel = nil ;
    for (MarkdownModel *model in modellist) {
        tmpModel = model ;
        if (model.type < MarkdownInlineUnknown) {
            return tmpModel ;
        }
    }
    return tmpModel ;
}

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

- (NSTextAttachment *)attachmentStandardFromImage:(UIImage *)image {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init] ;
    attachment.image             = image;
    CGFloat tvWid                = APP_WIDTH - 10 - kMDEditor_FlexValue ;
    CGSize resultImgSize         = CGSizeMake(tvWid, tvWid / image.size.width * image.size.height);
    CGRect rect                  = (CGRect){CGPointZero, resultImgSize};
    attachment.bounds            = rect;
    return attachment ;
}

// do when editor launch . (insert img placeholder)
- (NSMutableAttributedString *)readArticleFirstTimeAndInsertImagePHWhenEditorDidLaunching:(NSString *)text
                                                                                 textView:(UITextView *)textView {
    NSMutableArray *imageModelList = [@[] mutableCopy] ;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text] ;
    [str beginEditing] ;
    
    NSRegularExpression *expLink = regexp(MDIL_LINKS, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsLink = [expLink matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsLink) {
        NSString *prefixCha = [[text substringWithRange:result.range] substringWithRange:NSMakeRange(0, 1)] ;
        if ([prefixCha isEqualToString:@"!"]) {
            MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineImage range:result.range str:[text substringWithRange:result.range]] ;
            [imageModelList addObject:resModel] ;
        }
    }
    
    [imageModelList enumerateObjectsUsingBlock:^(MdInlineModel * _Nonnull imgModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *imgUrl = [imgModel imageUrl] ;

        NSInteger loc = imgModel.range.location + imgModel.range.length + idx ;
        UIImage *imgResult = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:imgUrl] ;
        if (!imgResult) {
            imgResult = self.imgManager.imagePlaceHolder ;
        }
        NSTextAttachment *attach = [self attachmentStandardFromImage:imgResult] ;
        NSAttributedString *attrAttach = [NSAttributedString attributedStringWithAttachment:attach] ;
        [str insertAttributedString:attrAttach atIndex:loc] ;
    }] ;
    
    [str endEditing] ;
    [self updateAttributedText:str textView:textView] ;
    
    return str ;
}

// in parse time . update image or download image.
- (NSMutableAttributedString *)updateImages:(NSString *)text
                                   textView:(UITextView *)textView {
    NSMutableArray *imageModelList = [@[] mutableCopy] ;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text] ;
    [str beginEditing] ;
    
    NSRegularExpression *expLink = regexp(MDIL_LINKS, NSRegularExpressionAnchorsMatchLines) ;
    NSArray *matsLink = [expLink matchesInString:text options:0 range:NSMakeRange(0, text.length)] ;
    for (NSTextCheckingResult *result in matsLink) {
        NSString *prefixCha = [[text substringWithRange:result.range] substringWithRange:NSMakeRange(0, 1)] ;
        if ([prefixCha isEqualToString:@"!"]) {
            MdInlineModel *resModel = [MdInlineModel modelWithType:MarkdownInlineImage range:result.range str:[text substringWithRange:result.range]] ;
            [imageModelList addObject:resModel] ;
        }
    }
    
    [imageModelList enumerateObjectsUsingBlock:^(MdInlineModel * _Nonnull imgModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *imgUrl = [imgModel imageUrl] ;
        
        NSInteger loc = imgModel.range.location + imgModel.range.length ;
        UIImage *imgResult = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:imgUrl] ;
        if (!imgResult) {
            imgResult = self.imgManager.imagePlaceHolder ;
            [self.imgManager imageWithUrlStr:imgUrl complete:^(UIImage * _Nonnull image) {
                
                NSTextAttachment *attach = [self attachmentStandardFromImage:image] ;
                NSAttributedString *attrAttach = [NSAttributedString attributedStringWithAttachment:attach] ;
                [str replaceCharactersInRange:NSMakeRange(loc, 1) withAttributedString:attrAttach] ;
                [self updateAttributedText:str textView:textView] ;
            }] ;
        }
        
        NSTextAttachment *attach = [self attachmentStandardFromImage:imgResult] ;
        NSAttributedString *attrAttach = [NSAttributedString attributedStringWithAttachment:attach] ;        [str replaceCharactersInRange:NSMakeRange(loc, 1) withAttributedString:attrAttach] ;
    }] ;
    [str endEditing] ;
    
    return str ;
}

@end
