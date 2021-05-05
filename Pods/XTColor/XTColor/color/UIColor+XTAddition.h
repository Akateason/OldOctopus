//
//  UIColor+XTAddition.h
//  XTColor
//
//  Created by teason23 on 2018/5/29.
//  Copyright © 2018年 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XTAddition)

/**
 Get color in Gradient Color
 
 @param percent 0 ~ 1
 */
+ (UIColor *)xt_colorBetweengGradientColor:(UIColor *)startColor
                                  andColor:(UIColor *)endColor
                                   percent:(CGFloat)percent ;

+ (UIColor *)xt_colorWithHexString:(NSString *)color ;
+ (UIColor *)xt_colorWithHexString:(NSString *)color
                             alpha:(float)alpha ;

@end
