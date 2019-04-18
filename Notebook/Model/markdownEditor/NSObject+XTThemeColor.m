//
//  NSObject+XTThemeColor.m
//  Notebook
//
//  Created by teason23 on 2019/4/12.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "NSObject+XTThemeColor.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"


@implementation NSObject (XTThemeColor)

- (void)setXt_theme_backgroundColor:(NSString *)xt_theme_backgroundColor {
    objc_setAssociatedObject(self, @selector(xt_theme_backgroundColor), xt_theme_backgroundColor, OBJC_ASSOCIATION_COPY_NONATOMIC) ;
    [self registerXTThemeNotification] ;
    [self renderBGColor:xt_theme_backgroundColor] ;
}

- (NSString *)xt_theme_backgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXt_theme_textColor:(NSString *)xt_theme_textColor {
    objc_setAssociatedObject(self, @selector(xt_theme_textColor), xt_theme_textColor, OBJC_ASSOCIATION_COPY_NONATOMIC) ;
    [self registerXTThemeNotification] ;
    [self renderTextColor:xt_theme_textColor] ;
}

- (NSString *)xt_theme_textColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXt_theme_imageColor:(NSString *)xt_theme_imageColor {
    objc_setAssociatedObject(self, @selector(xt_theme_imageColor), xt_theme_imageColor, OBJC_ASSOCIATION_COPY_NONATOMIC) ;
    [self registerXTThemeNotification] ;
    [self renderImageColor:xt_theme_imageColor] ;
}

- (NSString *)xt_theme_imageColor {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)renderImageColor:(NSString *)imgColor {
    UIColor *themeColor = [self themeColor:imgColor] ;
    
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImage *originImage = ((UIImageView *)self).image ;
        originImage = [originImage imageWithTintColor:themeColor] ;
        ((UIImageView *)self).image = originImage ;
    }
    else if ([self isKindOfClass:[UIButton class]]) {
        UIImage *originImage = ((UIButton *)self).currentImage ;
        originImage = [originImage imageWithTintColor:themeColor] ;
        [((UIImageView *)self) setImage:originImage] ;
    }
}

- (void)renderTextColor:(NSString *)textColor {
    UIColor *themeColor = [self themeColor:textColor] ;
    if ([self isKindOfClass:[UIButton class]]) {
        [(UIButton *)self setTitleColor:themeColor forState:0] ;
    }
    else if ([self isKindOfClass:[UILabel class]]) {
        [(UILabel *)self setTextColor:themeColor] ;
    }
    else if ([self isKindOfClass:[UITextView class]]) {
        [(UITextView *)self setTextColor:themeColor] ;
    }
    else if ([self isKindOfClass:[UITextField class]]) {
        [(UITextField *)self setTextColor:themeColor] ;
    }
    else {
        [self setValue:themeColor forKey:@"textColor"] ;
    }
}

- (void)renderBGColor:(NSString *)bgColor {
    UIColor *themeColor = [self themeColor:bgColor] ;
    
    if ([self isKindOfClass:[UIView class]]) {
        [(UIView *)self setBackgroundColor:themeColor] ;
    }
    else if ([self isKindOfClass:[UIBarButtonItem class]]) {
        [(UIBarButtonItem *)self setTintColor:themeColor] ;
    }
    else {
        [self setValue:themeColor forKey:@"backgroundColor"] ;
    }
}

- (void)registerXTThemeNotification {
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         if (self.xt_theme_backgroundColor) {
             [self renderBGColor:self.xt_theme_backgroundColor] ;
         }
         
         if (self.xt_theme_textColor) {
             [self renderTextColor:self.xt_theme_textColor] ;
         }
         
         if (self.xt_theme_imageColor) {
             [self renderImageColor:self.xt_theme_imageColor] ;
         }
     }] ;
}

- (UIColor *)themeColor:(NSString *)key {
    UIColor *themeColor ;
    if ([key containsString:@","]) {
        NSArray *list = [key componentsSeparatedByString:@","] ;
        themeColor = XT_MD_THEME_COLOR_KEY_A(list.firstObject, [list.lastObject floatValue]) ;
    }
    else {
        themeColor = XT_MD_THEME_COLOR_KEY(key) ;
    }
    return themeColor ;
}

@end
