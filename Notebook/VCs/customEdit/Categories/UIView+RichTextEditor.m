//
//  UIView+RichTextEditor.m
//  Notebook
//
//  Created by teason23 on 2019/2/21.
//  Copyright © 2019 teason23. All rights reserved.


#import "UIView+RichTextEditor.h"


@implementation UIView (RichTextEditor)

- (UIColor *)colorOfPoint:(CGPoint)point {
    unsigned char pixel[4]     = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context       = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (uint32_t)kCGImageAlphaPremultipliedLast);

    CGContextTranslateCTM(context, -point.x, -point.y);

    [self.layer renderInContext:context];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0] / 255.0 green:pixel[1] / 255.0 blue:pixel[2] / 255.0 alpha:pixel[3] / 255.0];

    return color;
}

- (UIViewController *)firstAvailableViewController {
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    }
    else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    }
    else {
        return nil;
    }
}

@end
