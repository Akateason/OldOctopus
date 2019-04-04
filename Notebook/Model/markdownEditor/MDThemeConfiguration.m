//
//  MDThemeConfiguration.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDThemeConfiguration.h"
#import <XTlib/XTlib.h>



@interface MDThemeConfiguration ()

@end

@implementation MDThemeConfiguration

XT_SINGLETON_M(MDThemeConfiguration)

#pragma mark - lazyload default style

// editor

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
            NSDictionary * object = @{NSFontAttributeName : self.font,
                                      NSForegroundColorAttributeName : self.textColor
                                      };
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
        _quoteStyle = @{NSForegroundColorAttributeName : self.quoteTextColor ,
                        NSFontAttributeName : self.font ,
                        NSParagraphStyleAttributeName : paragraphStyle
                      };
    }
    return _quoteStyle ;
}

- (NSDictionary *)markStyle {
    if(!_markStyle){
        _markStyle = ({
            NSDictionary * object = @{NSForegroundColorAttributeName : self.markColor} ;
            object;
       });
    }
    return _markStyle;
}

- (NSDictionary *)invisibleMarkStyle {
    if (!_invisibleMarkStyle) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        _invisibleMarkStyle = @{NSForegroundColorAttributeName : self.markColor,
                                NSFontAttributeName : [UIFont systemFontOfSize:0.1] ,
                                NSParagraphStyleAttributeName: paragraphStyle
                                } ;
    }
    return _invisibleMarkStyle ;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor] ; //UIColorHex(@"303133") ;
    }
    return _textColor ;
}

- (UIColor *)markColor {
    if (!_markColor) {
        _markColor = UIColorHex(@"909399") ;
    }
    return _markColor ;
}

- (UIColor *)seplineLineColor {
    if (!_seplineLineColor) {
        _seplineLineColor = UIColorHex(@"e5e5e5") ;
    }
    return _seplineLineColor ;
}

- (NSDictionary *)codeBlockStyle {
    if (!_codeBlockStyle) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = 25 ;
        _codeBlockStyle = @{NSBackgroundColorAttributeName : UIColorHexA(@"f05d4a", .3) ,
                      NSFontAttributeName : self.font ,
                      NSForegroundColorAttributeName : UIColorHex(@"3e403f") ,
                      NSParagraphStyleAttributeName : paragraphStyle
                      };
    }
    return _codeBlockStyle ;
}

- (UIColor *)inlineCodeBGColor {
    if (!_inlineCodeBGColor) {
        _inlineCodeBGColor = UIColorHex(@"f0f1f1") ;
    }
    return _inlineCodeBGColor ;
}

- (UIColor *)quoteTextColor {
    if (!_quoteTextColor) {
        _quoteTextColor = UIColorHex(@"777777") ;
    }
    return _quoteTextColor ;
}

- (UIColor *)quoteLeftBarColor {
    return self.themeColor ;
}

- (UIColor *)imagePlaceHolderColor {
    if (!_imagePlaceHolderColor) {
        _imagePlaceHolderColor = UIColorHexA(@"000000", .04) ;
    }
    return _imagePlaceHolderColor ;
}



// skin
- (UIColor *)themeColor {
    if (!_themeColor) {
        _themeColor = UIColorHex(@"f05d4a") ;
    }
    return _themeColor ;
}

- (UIColor *)homeTitleTextColor {
    if (!_homeTitleTextColor) {
        _homeTitleTextColor = UIColorHex(@"222222") ;
    }
    return _homeTitleTextColor ;
}

- (UIColor *)darkTextColor {
    if (!_darkTextColor) {
        _darkTextColor = [UIColor colorWithWhite:0 alpha:.8] ;
    }
    return _darkTextColor ;
}

- (UIColor *)lightTextColor {
    if (!_lightTextColor) {
        _lightTextColor = [UIColor colorWithWhite:0 alpha:.4] ;
    }
    return _lightTextColor ;
}

- (UIColor *)homeTableBGColor {
    if (!_homeTableBGColor) {
        _homeTableBGColor = [UIColor colorWithWhite:0 alpha:0.01] ;
    }
    return _homeTableBGColor ;
}

@end
