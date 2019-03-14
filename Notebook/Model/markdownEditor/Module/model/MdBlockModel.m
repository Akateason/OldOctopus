//
//  MdBlockModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdBlockModel.h"
#import <XTlib/XTlib.h>

@implementation MdBlockModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: str = @"引用" ; break ;
        case MarkdownSyntaxCodeBlock: str = @"代码块" ; break ;
        case MarkdownSyntaxHr: str = @"分割线" ; break ;
        default:
            break;
    }
    return str ;
}

- (NSDictionary *)attrQuoteBlockHideMark {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = 16;
    NSDictionary *tmpStyle = @{NSForegroundColorAttributeName:[UIColor whiteColor] ,
                               NSBackgroundColorAttributeName:[UIColor whiteColor] ,
                               NSFontAttributeName : [UIFont systemFontOfSize:0.1] ,
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
            
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 3, 3)] ;
        }
            break ;
        case MarkdownSyntaxHr: {
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            paraStyle.paragraphSpacing = 16 ;
            UIFont *hrFont = [UIFont systemFontOfSize:4] ;
            resultDic = @{NSBackgroundColorAttributeName : UIColorHex(@"dcdcdc") ,
                          NSForegroundColorAttributeName : UIColorHex(@"dcdcdc") ,
                          NSFontAttributeName : hrFont ,
                          NSParagraphStyleAttributeName : paraStyle
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
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
            
            // hide mark
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
            
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 3, 3)] ;
        }
            break ;
        case MarkdownSyntaxHr: {
            resultDic = @{NSBackgroundColorAttributeName : [UIColor clearColor] ,
                          NSForegroundColorAttributeName : configuration.markColor ,
                          NSFontAttributeName : configuration.font,
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break;
            
        default:
            break;
    }
    
    return attributedString ;
}

@end
