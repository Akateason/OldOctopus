//
//  UIView+OctupusExtension.m
//  Notebook
//
//  Created by teason23 on 2019/4/18.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UIView+OctupusExtension.h"
#import "MDThemeConfiguration.h"
#import <XTlib/XTlib.h>
#import <QuartzCore/QuartzCore.h>
#import "SettingSave.h"

@implementation UIView (OctupusExtension)

- (void)oct_addBlurBg {
    BOOL isDarkMode = [[MDThemeConfiguration sharedInstance].currentThemeKey containsString:@"dark"] ||
    [[MDThemeConfiguration sharedInstance].currentThemeKey containsString:@"midnight"] ;
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight] ;
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct] ;

    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:visualEffectView atIndex:0] ;
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self) ;
    }] ;
}

- (UIImage *)blur:(UIImage *)theImage {
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

+ (UIImage *) scaleIfNeeded:(CGImageRef)cgimg {
    bool isRetina = [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0;
    if (isRetina) {
        return [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
    }
    else {
        return [UIImage imageWithCGImage:cgimg];
    }
}

- (UIImage *)reOrientIfNeeded:(UIImage*)theImage{
    
    if (theImage.imageOrientation != UIImageOrientationUp) {
        
        CGAffineTransform reOrient = CGAffineTransformIdentity;
        switch (theImage.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, theImage.size.height);
                reOrient = CGAffineTransformRotate(reOrient, M_PI);
                break;
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
                reOrient = CGAffineTransformRotate(reOrient, M_PI_2);
                break;
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, 0, theImage.size.height);
                reOrient = CGAffineTransformRotate(reOrient, -M_PI_2);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
        
        switch (theImage.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
                reOrient = CGAffineTransformScale(reOrient, -1, 1);
                break;
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.height, 0);
                reOrient = CGAffineTransformScale(reOrient, -1, 1);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                break;
        }
        
        CGContextRef myContext = CGBitmapContextCreate(NULL, theImage.size.width, theImage.size.height, CGImageGetBitsPerComponent(theImage.CGImage), 0, CGImageGetColorSpace(theImage.CGImage), CGImageGetBitmapInfo(theImage.CGImage));
        
        CGContextConcatCTM(myContext, reOrient);
        
        switch (theImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.height,theImage.size.width), theImage.CGImage);
                break;
                
            default:
                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.width,theImage.size.height), theImage.CGImage);
                break;
        }
        
        CGImageRef CGImg = CGBitmapContextCreateImage(myContext);
        theImage = [UIImage imageWithCGImage:CGImg];
        
        CGImageRelease(CGImg);
        CGContextRelease(myContext);
    }
    
    return theImage;
}






- (void)oct_buttonClickAnimationComplete:(void(^)(void))completion {
    [self oct_buttonClickAnimationWithScale:1.2 complete:completion] ;
}

- (void)oct_buttonClickAnimationWithScale:(float)scale
                                 complete:(void(^)(void))completion {
    
    SettingSave *sSave = [SettingSave fetch] ;
    float duration = [sSave currentAnimationDuration] ;
    
    if (sSave.animate_isSpring) {
        [UIView animateWithDuration:duration / 2. delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{

            self.transform = CGAffineTransformMakeScale(scale, scale) ;

        } completion:^(BOOL finished) {
                                    
            [UIView animateWithDuration:duration + .2 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:100 * duration options:UIViewAnimationOptionLayoutSubviews animations:^{

                self.transform = CGAffineTransformIdentity;

            } completion:^(BOOL finished) {
                if (completion) completion() ;
            }] ;
        }] ;
    }
    else {
        [UIView animateWithDuration:duration / 2. delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            self.transform = CGAffineTransformMakeScale(scale, scale) ;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (completion) completion() ;
            }] ;
        }] ;
    }
}



@end
