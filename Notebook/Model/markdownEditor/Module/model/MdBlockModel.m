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

@implementation MdBlockModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: str = @"引用" ; break ;
        case MarkdownSyntaxCodeBlock: str = @"</>" ; break ;
        
        default:
            break;
    }
    return str ;
}

- (NSDictionary *)attrQuoteBlockHideMark {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.paragraphSpacing = 16;
    NSDictionary *tmpStyle = @{NSForegroundColorAttributeName:[UIColor whiteColor] ,
                               NSBackgroundColorAttributeName:[UIColor whiteColor] ,
                               NSFontAttributeName : [UIFont systemFontOfSize:.1] ,
                               } ;
    return tmpStyle ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: {
            [attributedString addAttributes:configuration.quoteStyle range:self.range] ;
            
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
            resultDic = @{NSBackgroundColorAttributeName : configuration.codeTextBGColor,
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:self.range] ;
            
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
                                           config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: {
            [attributedString addAttributes:configuration.quoteStyle range:self.range] ;
            
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
            resultDic = @{NSBackgroundColorAttributeName : configuration.codeTextBGColor,
                          NSFontAttributeName : paragraphFont
                          } ;
            NSRange rangeTmp = NSMakeRange(location + 3, length - 6) ;
            [attributedString addAttributes:resultDic range:rangeTmp] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}

+ (void)toolbarEventQuoteBlock:(MarkdownEditor *)editor {
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@">  " atIndex:editor.selectedRange.location] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 2, 0) ;
        [editor.markdownPaser parseText:tmpString position:editor.selectedRange.location textView:editor] ;
        return ;
    }
    // replace
    if (paraModel.type == MarkdownSyntaxBlockquotes) return ;
    [tmpString insertString:@"> " atIndex:paraModel.range.location] ;
    [editor.markdownPaser parseText:tmpString position:paraModel.range.location textView:editor] ;
    [editor doSomethingWhenUserSelectPartOfArticle] ;
}

+ (void)toolbarEventCodeBlock:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"```\n \n```" atIndex:editor.selectedRange.location] ;
        [editor.markdownPaser parseText:tmpString position:editor.selectedRange.location textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 4, 0) ;
        [editor doSomethingWhenUserSelectPartOfArticle] ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxCodeBlock) return ;
    [tmpString insertString:@"\n```" atIndex:paraModel.range.location + paraModel.range.length] ;
    [tmpString insertString:@"```\n" atIndex:paraModel.range.location] ;
    [editor.markdownPaser parseText:tmpString position:editor.selectedRange.location textView:editor] ;
    [editor doSomethingWhenUserSelectPartOfArticle] ;
}

@end
