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



- (void)changeTheme:(NSString *)theme {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:theme ofType:@"json"] ;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    self.dicForColors = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [self editorThemeObj] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForThemeColorDidChanged object:nil] ;
}

- (NSDictionary *)dicForColors {
    if (!_dicForColors) {
        NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"themeDefault" ofType:@"json"] ;
        NSData *data = [[NSData alloc] initWithContentsOfFile:path] ;
        _dicForColors = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] ;
    }
    return _dicForColors ;
}

- (UIColor *)colorWithThemeKey:(NSString *)key alpha:(float)alpha {
    return UIColorHexA(self.dicForColors[key], alpha) ;
}

- (UIColor *)colorWithThemeKey:(NSString *)key {
    return UIColorHex(self.dicForColors[key]) ;
}


- (MDEditorTheme *)editorThemeObj {
    if (!_editorThemeObj) {
        _editorThemeObj = [MDEditorTheme new] ;
    }
    return _editorThemeObj ;
}











//
//#pragma mark - lazyload default style
//
//// editor
//
//- (UIColor *)textColor {
//    if (!_textColor) {
//        _textColor = [UIColor blackColor] ; //UIColorHex(@"303133") ;
//    }
//    return _textColor ;
//}
//
//- (UIColor *)markColor {
//    if (!_markColor) {
//        _markColor = UIColorHex(@"909399") ;
//    }
//    return _markColor ;
//}
//
//- (UIColor *)seplineLineColor {
//    if (!_seplineLineColor) {
//        _seplineLineColor = UIColorHex(@"e5e5e5") ;
//    }
//    return _seplineLineColor ;
//}
//
//
//- (UIColor *)inlineCodeBGColor {
//    if (!_inlineCodeBGColor) {
//        _inlineCodeBGColor = UIColorHex(@"f0f1f1") ;
//    }
//    return _inlineCodeBGColor ;
//}
//
//- (UIColor *)quoteTextColor {
//    if (!_quoteTextColor) {
//        _quoteTextColor = UIColorHex(@"777777") ;
//    }
//    return _quoteTextColor ;
//}
//
//- (UIColor *)quoteLeftBarColor {
//    return self.themeColor ;
//}
//
//- (UIColor *)imagePlaceHolderColor {
//    if (!_imagePlaceHolderColor) {
//        _imagePlaceHolderColor = UIColorHexA(@"000000", .04) ;
//    }
//    return _imagePlaceHolderColor ;
//}
//
//
//
//// skin
//- (UIColor *)themeColor {
//    if (!_themeColor) {
//        _themeColor = UIColorHex(self.themeColorHex) ;
//    }
//    return _themeColor ;
//}
//
//- (NSString *)themeColorHex {
//    if (!_themeColorHex) {
//        _themeColorHex = @"f05d4a" ;
//    }
//    return _themeColorHex ;
//}
//
//- (UIColor *)homeTitleTextColor {
//    if (!_homeTitleTextColor) {
//        _homeTitleTextColor = UIColorHex(@"222222") ;
//    }
//    return _homeTitleTextColor ;
//}
//
//- (UIColor *)darkTextColor {
//    if (!_darkTextColor) {
//        _darkTextColor = [UIColor colorWithWhite:0 alpha:.8] ;
//    }
//    return _darkTextColor ;
//}
//
//- (UIColor *)lightTextColor {
//    if (!_lightTextColor) {
//        _lightTextColor = [UIColor colorWithWhite:0 alpha:.4] ;
//    }
//    return _lightTextColor ;
//}
//
//- (UIColor *)homeTableBGColor {
//    if (!_homeTableBGColor) {
//        _homeTableBGColor = [UIColor colorWithWhite:0 alpha:0.01] ;
//    }
//    return _homeTableBGColor ;
//}

@end
