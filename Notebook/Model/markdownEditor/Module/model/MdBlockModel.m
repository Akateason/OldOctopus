//
//  MdBlockModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdBlockModel.h"
#import <XTlib/XTlib.h>
#import "MarkdownEditor.h"
#import "MarkdownEditor+UtilOfToolbar.h"
#import "XTMarkdownParser+Fetcher.h"

@implementation MdBlockModel

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str level:(int)level {
    MdBlockModel *model = [super modelWithType:type range:range str:str level:level] ;
    
    // 引用嵌套其他blk的处理
    if (model.type == MarkdownSyntaxBlockquotes) {
        XTMarkdownParser *parser = [XTMarkdownParser new] ;
        MarkdownModel *tmpModel = [model copy] ;
        NSUInteger cutNumber = 0 ;
        NSString *newStr ;
        
        NSString *prefix = [[tmpModel.str componentsSeparatedByString:@">"] firstObject] ;
        cutNumber = prefix.length ;
        newStr = [tmpModel.str substringFromIndex:cutNumber + 1] ;
        while ([newStr hasPrefix:@" "]) {
            newStr = [newStr substringFromIndex:1] ;
            cutNumber++ ;
        }
        
        tmpModel.str = newStr ;
        tmpModel.range = NSMakeRange(tmpModel.range.location + cutNumber + 1, tmpModel.range.length - cutNumber - 1) ;
        tmpModel.quoteAndList_Level ++ ;
        
        // 递归
        MarkdownModel *subModel = [parser parsingGetABlockStyleModelFromParaModel:tmpModel] ;
        if (subModel.type <= NumberOfMarkdownSyntax && subModel.type > 0) {            
            model.subBlkModel = subModel ;
        }
        tmpModel = nil ;
    }
    
    return model ;
}


- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: str = @"md_tb_bt_quote"     ; break ;
        case MarkdownSyntaxCodeBlock: str   = @"md_tb_bt_blkCode"   ; break ;
        
        default:
            break;
    }
    return str ;
}

- (NSDictionary *)attrQuoteBlockHideMarkWithLevel {
    int level = self.textIndentationPosition ;
    level++ ;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init] ;
    paraStyle.firstLineHeadIndent = 18 * level ;
    paraStyle.headIndent = 18 * level ;
    paraStyle.lineSpacing = 10 ;
    NSDictionary *tmpStyle = @{
                               NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                               NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                               NSFontAttributeName : [UIFont systemFontOfSize:.1] ,
                               NSParagraphStyleAttributeName : paraStyle,
                               } ;
    return tmpStyle ;
}

- (NSDictionary *)attrCodeBlockHideMark {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init] ;
    paraStyle.paragraphSpacing = 0 ;
    NSDictionary *tmpStyle = @{
                                NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                                NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                                NSFontAttributeName : [UIFont systemFontOfSize:.1] ,
                                NSParagraphStyleAttributeName : paraStyle,
                               } ;
    return tmpStyle ;
}


- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: {
            [attributedString addAttributes:configuration.editorThemeObj.quoteStyle range:self.range] ;
            
            // hide ">" mark
            NSRegularExpression *expression = regexp("(\\>\\s)|(\\>)", 0) ;
//            NSRegularExpression *expression = regexp("(\\>)", 0) ;
            NSArray *matches = [expression matchesInString:self.str options:0 range:NSMakeRange(0, [self.str length])] ;
            for (NSTextCheckingResult *result in matches) {
                NSRange bqRange = NSMakeRange(location + result.range.location, result.range.length) ;
                [attributedString addAttributes:[self attrQuoteBlockHideMarkWithLevel] range:bqRange] ;
            }
        }
            break ;
        case MarkdownSyntaxCodeBlock: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
            
            resultDic = [self attrCodeBlockHideMark] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + length - 3, 3)] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: {
            [attributedString addAttributes:configuration.editorThemeObj.quoteStyle range:self.range] ;
            
            // hide ">" mark
            NSRegularExpression *expression = regexp("(\\>\\s)|(\\>)", 0) ;
            NSArray *matches = [expression matchesInString:self.str options:0 range:NSMakeRange(0, [self.str length])] ;
            for (NSTextCheckingResult *result in matches) {
                NSRange bqRange = NSMakeRange(location + result.range.location, result.range.length) ;
                [attributedString addAttributes:[self attrQuoteBlockHideMarkWithLevel] range:bqRange] ;
            }
        }
            break ;
        case MarkdownSyntaxCodeBlock: {
//            NSRange rangeTmp = NSMakeRange(location + 3, length - 6) ;
//            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:rangeTmp] ;
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}



+ (void)toolbarEventQuoteBlock:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@">  " atIndex:editor.selectedRange.location] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 2, 0) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        return ;
    }
    // replace
    if (paraModel.type == MarkdownSyntaxBlockquotes) return ;
    [tmpString insertString:@"> " atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:paraModel.range.location textView:editor] ;
    MarkdownModel *modelParse = [editor.parser modelForModelListBlockFirst] ;
    [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
    editor.selectedRange = NSMakeRange(modelParse.range.length + modelParse.range.location, 0) ;
}

+ (void)toolbarEventCodeBlock:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"```\n \n```" atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        id modelParse = [editor.parser modelForModelListBlockFirst] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 4, 0) ;
        [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxCodeBlock) return ;
    
    [tmpString insertString:@"\n```" atIndex:paraModel.range.location + paraModel.range.length] ;
    [tmpString insertString:@"```\n" atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
    MarkdownModel *modelParse = [editor.parser modelForModelListBlockFirst] ;
    [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
    editor.selectedRange = NSMakeRange(modelParse.range.length + modelParse.range.location, 0) ;

}






+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range {
    
    NSMutableString *tmpString = [textView.text mutableCopy] ;
    NSString *insertQuoteString = @"\n> " ;
    
    if (aModel.type == MarkdownSyntaxBlockquotes) {
        if ([aModel.str isEqualToString:@"> "]) {     // 两下回车, 删除mark
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - aModel.str.length, aModel.str.length)] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location - aModel.str.length textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location - aModel.str.length, 0) ;
            return YES ;
        }
        
        [tmpString insertString:insertQuoteString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertQuoteString.length, 0) ;
        
        return NO ;
    }
    
    return 100 ; // 未知情况, 传到下一个model去处理
}




@end
