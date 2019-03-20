//
//  MdInlineModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdInlineModel.h"
#import <XTlib/XTlib.h>

@implementation MdInlineModel

- (NSString *)displayStringForLeftLabel {
    
    NSString *str = [super displayStringForLeftLabel] ;
    switch (self.type) {
        case MarkdownInlineBold: str = @"B" ; break ;
        case MarkdownInlineItalic: str = @"I" ; break ;
        case MarkdownInlineBoldItalic: str = @"BI" ; break ;
        case MarkdownInlineDeletions: str = @"D" ; break ;
        case MarkdownInlineInlineCode: str = @"hn代码" ; break ;
        case MarkdownInlineLinks: str = @"link" ; break ;
        case MarkdownInlineImage: str = @"image" ; break ;
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
        case MarkdownInlineBold: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldFont} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineItalic: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSFontAttributeName : configuration.italicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownInlineBoldItalic: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 3, 3)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldItalicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownInlineDeletions: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineInlineCode: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSBackgroundColorAttributeName : configuration.codeTextBGColor,
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownInlineLinks: {
            // todo links with attr str
            [attributedString addAttributes:configuration.invisibleMarkStyle range:self.range] ;
            
            resultDic = @{NSForegroundColorAttributeName : [UIColor xt_skyBlue],
                          NSFontAttributeName : paragraphFont,
                          NSUnderlineStyleAttributeName : @1
                          };
            NSString *prefixAddFKH = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
            NSRange tmpRange = NSMakeRange(location + 1, prefixAddFKH.length - 1) ;
            [attributedString addAttributes:resultDic range:tmpRange] ;
        }
            break ;
        case MarkdownInlineImage : {
            resultDic = @{NSForegroundColorAttributeName : [UIColor xt_lightOrange],
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
        case MarkdownInlineBold: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldFont} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineItalic: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSFontAttributeName : configuration.italicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownInlineBoldItalic: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 3, 3)] ;
            
            resultDic = @{NSFontAttributeName : configuration.boldItalicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownInlineDeletions: {
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.markStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineInlineCode: {
            resultDic = @{NSBackgroundColorAttributeName : configuration.codeTextBGColor,
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownInlineLinks: {
            [attributedString addAttributes:configuration.markStyle range:self.range] ;
            
            resultDic = @{NSForegroundColorAttributeName : [UIColor xt_skyBlue],
                          NSFontAttributeName : paragraphFont,
                          NSUnderlineStyleAttributeName : @1
                          };
            NSString *prefixAddFKH = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
            NSRange tmpRange = NSMakeRange(location + 1, prefixAddFKH.length - 1) ;
            [attributedString addAttributes:resultDic range:tmpRange] ;
        }
            break ;
        case MarkdownInlineImage : {
            resultDic = @{NSForegroundColorAttributeName : [UIColor xt_lightOrange],
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
