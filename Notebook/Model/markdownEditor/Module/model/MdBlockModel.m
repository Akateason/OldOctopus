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

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: str = @"md_tb_bt_quote" ; break ;
        case MarkdownSyntaxCodeBlock: str = @"md_tb_bt_blkCode" ; break ;
        
        default:
            break;
    }
    return str ;
}

- (NSDictionary *)attrQuoteBlockHideMark {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.paragraphSpacing = 0 ;
    NSDictionary *tmpStyle = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                               NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_bgColor, .3) ,
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
            NSRegularExpression *expression = regexp("(^\\>\\s)|(^\\>)", NSRegularExpressionAnchorsMatchLines) ;
            NSArray *matches = [expression matchesInString:self.str options:0 range:NSMakeRange(0, [self.str length])] ;
            for (NSTextCheckingResult *result in matches) {
                NSRange bqRange = NSMakeRange(location + result.range.location, result.range.length) ;
                [attributedString addAttributes:[self attrQuoteBlockHideMark] range:bqRange] ;
            }
        }
            break ;
        case MarkdownSyntaxCodeBlock: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
            
            resultDic = [self attrQuoteBlockHideMark] ;
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
            NSRegularExpression *expression = regexp("(^\\>\\s)|(^\\>)", NSRegularExpressionAnchorsMatchLines) ;
            NSArray *matches = [expression matchesInString:self.str options:0 range:NSMakeRange(0, [self.str length])] ;
            for (NSTextCheckingResult *result in matches) {
                NSRange bqRange = NSMakeRange(location + result.range.location, result.range.length) ;
                [attributedString addAttributes:[self attrQuoteBlockHideMark] range:bqRange] ;
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

@end
