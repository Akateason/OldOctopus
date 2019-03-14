//
//  MdInlineModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdInlineModel.h"

@implementation MdInlineModel

- (NSString *)displayStringForLeftLabel {
    
    NSString *str = [super displayStringForLeftLabel] ;
    switch (self.type) {
        case MarkdownSyntaxBold: str = @"B" ; break ;
        case MarkdownSyntaxItalic: str = @"I" ; break ;
        case MarkdownSyntaxBoldItalic: str = @"BI" ; break ;
        case MarkdownSyntaxDeletions: str = @"D" ; break ;
        case MarkdownSyntaxInlineCode: str = @"hn代码" ; break ;
        case MarkdownSyntaxLinks: str = @"link" ; break ;
        default: break;
    }
    
    return str ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;

    switch (self.type) {
        case MarkdownSyntaxBold: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldFont} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownSyntaxItalic: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSFontAttributeName : configuration.italicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownSyntaxBoldItalic: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 3, 3)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldItalicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownSyntaxDeletions: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownSyntaxInlineCode: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSBackgroundColorAttributeName : configuration.codeTextBGColor,
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownSyntaxLinks: {
            // todo links with attr str
            resultDic = @{NSForegroundColorAttributeName : [UIColor blueColor],
                          NSFontAttributeName : paragraphFont
                          };
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
        case MarkdownSyntaxBold: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldFont} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownSyntaxItalic: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSFontAttributeName : configuration.italicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownSyntaxBoldItalic: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 3, 3)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldItalicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownSyntaxDeletions: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownSyntaxInlineCode: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSBackgroundColorAttributeName : configuration.codeTextBGColor,
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownSyntaxLinks: {
            resultDic = @{NSForegroundColorAttributeName : [UIColor blueColor],
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;

        default:
            break;
    }
    
    return attributedString ;
}

@end
