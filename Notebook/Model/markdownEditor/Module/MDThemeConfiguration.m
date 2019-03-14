//
//  MDThemeConfiguration.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDThemeConfiguration.h"
#import <XTlib/XTlib.h>

static int kDefaultFontSize = 16 ;

@interface MDThemeConfiguration ()

@end

@implementation MDThemeConfiguration

#pragma mark - lazyload default style

- (int)fontSize {
    if (!_fontSize) {
        _fontSize = kDefaultFontSize ;
    }
    return _fontSize ;
}

- (UIFont *)font{
    if(!_font){
        _font = ({
            UIFont *object = [UIFont systemFontOfSize:kDefaultFontSize] ;
            object;
       });
    }
    return _font;
}

- (UIFont *)boldFont{
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

- (UIFont *)italicFont{
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

- (UIFont *)boldItalicFont{
    if(!_boldItalicFont){
        _boldItalicFont = ({
            NSDictionary *fontDict = @{
                                       UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)],
                                       UIFontDescriptorFaceAttribute: @"Bold"
                                       } ;
            UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
            UIFont * object = [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
            object;
       });
    }
    return _boldItalicFont;
}

- (NSDictionary *)basicStyle{
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
        paragraphStyle.headIndent += 16;
        paragraphStyle.firstLineHeadIndent += 16;
        _quoteStyle = @{NSForegroundColorAttributeName : self.quoteTextColor,
                        NSFontAttributeName : self.font,
                        NSParagraphStyleAttributeName :paragraphStyle
                      };
    }
    return _quoteStyle ;
}

- (NSDictionary *)markStyle{
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
        _invisibleMarkStyle = @{NSForegroundColorAttributeName : self.markColor,
                                NSFontAttributeName : [UIFont systemFontOfSize:0]
                                } ;
    }
    return _invisibleMarkStyle ;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor] ;
    }
    return _textColor ;
}

- (UIColor *)markColor {
    if (!_markColor) {
        _markColor = UIColorHex(@"909399") ;
    }
    return _markColor ;
}

- (UIColor *)codeTextBGColor {
    if (!_codeTextBGColor) {
        _codeTextBGColor = UIColorHex(@"f0f1f1") ;
    }
    return _codeTextBGColor ;
}

- (UIColor *)quoteTextColor {
    if (!_quoteTextColor) {
        _quoteTextColor = UIColorHex(@"777777") ;
    }
    return _quoteTextColor ;
}

@end
