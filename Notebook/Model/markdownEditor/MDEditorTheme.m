//
//  MDEditorTheme.m
//  Notebook
//
//  Created by teason23 on 2019/4/12.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDEditorTheme.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"


@implementation MDEditorTheme

- (int)fontSize {
    if (!_fontSize) {
        _fontSize = kDefaultFontSize ;
    }
    return _fontSize ;
}

- (UIFont *)font {
    if(!_font){
        _font = ({
            UIFont *object = [UIFont systemFontOfSize:kDefaultFontSize] ;
            object;
        });
    }
    return _font;
}

- (UIFont *)boldFont {
    if(!_boldFont){
        _boldFont = ({
            NSDictionary *fontDict = @{UIFontDescriptorFaceAttribute: @"Bold"} ;
            UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
            UIFont *object = [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
            object;
        });
    }
    return _boldFont;
}

- (UIFont *)italicFont {
    if(!_italicFont){
        _italicFont = ({
            NSDictionary *fontDict = @{UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)]} ;
            UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
            UIFont * object = [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
            object;
        });
    }
    return _italicFont;
}

- (UIFont *)boldItalicFont {
    if(!_boldItalicFont){
        _boldItalicFont = ({
            NSDictionary *fontDict = @{
                                       UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)],
                                       UIFontDescriptorFaceAttribute:@"Bold"
                                       } ;
            UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
            UIFont * object = [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
            object;
        });
    }
    return _boldItalicFont;
}

- (NSDictionary *)basicStyle {
    if(!_basicStyle){
        _basicStyle = ({
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//            paragraphStyle.lineSpacing = 10 ;
//            paragraphStyle.paragraphSpacing = kDefaultFontSize ;
//            paragraphStyle.paragraphSpacingBefore = 2 * kDefaultFontSize ;
            NSDictionary * object = @{NSFontAttributeName : self.font,
                                      NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_textColor),
                                      NSParagraphStyleAttributeName : paragraphStyle
                                      } ;
            object;
        });
    }
    return _basicStyle;
}

- (NSDictionary *)quoteStyle {
    if (!_quoteStyle) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 16 ;
        paragraphStyle.firstLineHeadIndent = 16 ;
        _quoteStyle = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_quoteTextColor) ,
                        NSFontAttributeName : self.font ,
                        NSParagraphStyleAttributeName : paragraphStyle
                        };
    }
    return _quoteStyle ;
}

- (NSDictionary *)markStyle {
    if(!_markStyle){
        _markStyle = ({
            NSDictionary * object = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_markColor)} ;
            object;
        });
    }
    return _markStyle;
}

- (NSDictionary *)invisibleMarkStyle {
    if (!_invisibleMarkStyle) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        _invisibleMarkStyle = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_markColor),
                                NSFontAttributeName : [UIFont systemFontOfSize:0.1] ,
                                NSParagraphStyleAttributeName: paragraphStyle
                                } ;
    }
    return _invisibleMarkStyle ;
}

- (NSDictionary *)listInvisibleMarkStyle {
    if (!_listInvisibleMarkStyle) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        _listInvisibleMarkStyle = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_markColor),
                                    NSFontAttributeName : [UIFont systemFontOfSize:0.1] ,
                                    NSParagraphStyleAttributeName: paragraphStyle
                                    } ;
    }
    return _listInvisibleMarkStyle ;
}

- (NSDictionary *)codeBlockStyle {
    if (!_codeBlockStyle) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = 25 ;
        
        _codeBlockStyle = @{NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_themeColor, .3) ,
                            NSFontAttributeName : self.font ,
                            NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_themeColor) ,
                            NSParagraphStyleAttributeName : paragraphStyle
                            };
    }
    return _codeBlockStyle ;
}


@end


