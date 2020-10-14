//
//  UIImageView+XtHugeImageDownsize.m
//  XTBase
//
//  Created by teason23 on 2020/8/13.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "UIImageView+XtHugeImageDownsize.h"
#import "XTlibConst.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "CommonFunc.h"

/// HugeImageDownsize

#define bytesPerMB                  1048576.0f
#define bytesPerPixel               4.0f
#define pixelsPerMB                 ( bytesPerMB / bytesPerPixel ) // 262144 pixels, for 4 bytes per pixel.
#define destSeemOverlap             2.0f    // the numbers of pixels to overlap the seems where tiles meet.

typedef void(^BlkDownsizeComplete)(BOOL success);

@interface UIImageView ()
@property (nonatomic,assign) CGContextRef           destContext;
@property (nonatomic,assign) BOOL                   loaded;
@property (nonatomic,copy)   BlkDownsizeComplete    downsizeCompleteBlk;
@end

@implementation UIImageView (XTHugeImageDownsize)

- (void)xt_hugeImageDownsize:(UIImage *)image
            renderCompletion:(void(^)(BOOL success))completion {
    
    if (!image) {
        NSLog(@"input image not found!");
        if (completion) completion(NO);
        return;
    }
    
    RACTuple *info = [self makeInfoInCurrentDevice];
    RACTupleUnpack(NSNumber *destImageSizeMBNumber, NSNumber *sourceImageTileSizeMBNumber) = info;
    float kDestImageSizeMB = destImageSizeMBNumber.floatValue;
    float kSourceImageTileSizeMB = sourceImageTileSizeMBNumber.floatValue;
    float destTotalPixels = kDestImageSizeMB * pixelsPerMB;
    float tileTotalPixels = kSourceImageTileSizeMB * pixelsPerMB;
    
    @synchronized (self) {
        @autoreleasepool {
            self.loaded = YES;
            
            CGSize sourceResolution;
            float sourceTotalPixels;
            float sourceTotalMB;
            CGRect sourceTile;
            
            float imageScale;
            float sourceSeemOverlap;
            
            CGSize destResolution;
            CGRect destTile;
            
            UIImage *sourceImage = image;
            sourceResolution.width = CGImageGetWidth(sourceImage.CGImage);
            sourceResolution.height = CGImageGetHeight(sourceImage.CGImage);
            sourceTotalPixels = sourceResolution.width * sourceResolution.height;
            sourceTotalMB = sourceTotalPixels / pixelsPerMB;
            imageScale = destTotalPixels / sourceTotalPixels;
                        
            if (imageScale > 1.0f) { // 无需处理
                self.loaded = NO;
                if (completion) {
                    completion(YES);
                }
                return;
            }
            
            destResolution.width  = (int)( sourceResolution.width * imageScale );
            destResolution.height = (int)( sourceResolution.height * imageScale );
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            int bytesPerRow = bytesPerPixel * destResolution.width;
            void* destBitmapData = malloc( bytesPerRow * destResolution.height );
            if (destBitmapData == NULL) {
                self.loaded = NO;
                NSLog(@"failed to allocate space for the output image!");
                if (completion) completion(NO);
                return;
            }
            
            self.destContext = CGBitmapContextCreate( destBitmapData, destResolution.width, destResolution.height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast );
            if (self.destContext == NULL) {
                free( destBitmapData );
                self.loaded = NO;
                NSLog(@"failed to create the output bitmap context!");
                if (completion) completion(NO);
                return;
            }
            
            CGColorSpaceRelease( colorSpace );
            CGContextTranslateCTM( self.destContext, 0.0f, destResolution.height );
            CGContextScaleCTM( self.destContext, 1.0f, -1.0f );
            sourceTile.size.width = sourceResolution.width;
            sourceTile.size.height = (int)( tileTotalPixels / sourceTile.size.width );
            NSLog(@"source tile size: %f x %f",sourceTile.size.width, sourceTile.size.height);
            sourceTile.origin.x = 0.0f;
            destTile.size.width = destResolution.width;
            destTile.size.height = sourceTile.size.height * imageScale;
            destTile.origin.x = 0.0f;
            NSLog(@"dest tile size: %f x %f",destTile.size.width, destTile.size.height);
            // 重合的像素
            sourceSeemOverlap = (int)( ( destSeemOverlap / destResolution.height ) * sourceResolution.height );
            NSLog(@"dest seem overlap: %f, source seem overlap: %f",destSeemOverlap, sourceSeemOverlap);
            CGImageRef sourceTileImageRef;
            int iterations = (int)( sourceResolution.height / sourceTile.size.height );
            int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
            if( remainder ) iterations++;
            
            float sourceTileHeightMinusOverlap = sourceTile.size.height;
            sourceTile.size.height += sourceSeemOverlap;
            destTile.size.height += destSeemOverlap;
            NSLog(@"beginning downsize. iterations: %d, tile height: %f, remainder height: %d", iterations, sourceTile.size.height,remainder );
            
            for ( int y = 0; y < iterations; ++y ) {
                @autoreleasepool {
                    NSLog(@"iteration %d of %d",y + 1, iterations);
                    sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                    destTile.origin.y = ( destResolution.height ) - ( ( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + destSeemOverlap );
                    sourceTileImageRef = CGImageCreateWithImageInRect( sourceImage.CGImage, sourceTile );
                    if ( y == iterations - 1 && remainder ) {
                        float dify = destTile.size.height;
                        destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                        dify -= destTile.size.height;
                        destTile.origin.y += dify;
                    }
                    CGContextDrawImage( self.destContext, destTile, sourceTileImageRef );
                    CGImageRelease( sourceTileImageRef );
                    if ( y < iterations  ) {
                        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
                    }
                }
            }
            NSLog(@"downsize complete.");
            CGContextRelease( self.destContext );
            free(destBitmapData);
            
            self.loaded = NO;
                        
            if (completion) {
                completion(YES);
            }
        }
    }
}

- (void)createImageFromContext {
    CGImageRef destImageRef = CGBitmapContextCreateImage( self.destContext );
    if (destImageRef == NULL) NSLog(@"destImageRef is null.");
    self.image = [UIImage imageWithCGImage:destImageRef scale:1.0f orientation:UIImageOrientationDownMirrored];
    CGImageRelease( destImageRef );
    if (self.image == nil) NSLog(@"destImage is nil.");
}

- (void)updateView {
    [self createImageFromContext];
}

- (RACTuple *)makeInfoInCurrentDevice {
    CGFloat destImageSizeMB;// The resulting image will be (x)MB of uncompressed image data.
    CGFloat sourceImageTileSizeMB;// The tile size will be (x)MB of uncompressed image data.
    NSString *deviceInfo = [CommonFunc getDeviceName];
    if ([deviceInfo hasPrefix:@"iPhone1,"] || [deviceInfo hasPrefix:@"iPod1,"] || [deviceInfo hasPrefix:@"iPod2"] || [deviceInfo hasPrefix:@"iPhone5"] || [deviceInfo hasPrefix:@"iPhone6"] || [deviceInfo hasPrefix:@"iPhone7"]) { //IPHONE3G_IPOD2_AND_EARLIER + iphone4,5,6
        destImageSizeMB = 30.0f;
        sourceImageTileSizeMB = 10.0f;
    } else if ([deviceInfo hasPrefix:@"iPad1,"] || [deviceInfo hasPrefix:@"iPhone2"]) { // IPAD1_IPHONE3GS
        destImageSizeMB = 60.0f;
        sourceImageTileSizeMB = 20.0f;
    } else if ([deviceInfo hasPrefix:@"iPad2"] || [deviceInfo hasPrefix:@"iPhone4"] || [deviceInfo hasPrefix:@"iPhone3"] ) { // IPAD2_IPHONE4
        destImageSizeMB = 120.0f;
        sourceImageTileSizeMB = 40.0f;
    } else {
        destImageSizeMB = 60.0f;
        sourceImageTileSizeMB = 20.0f;
    }

    return RACTuplePack(@(destImageSizeMB),@(sourceImageTileSizeMB));
}

#pragma mark -- set && get

- (void)setDestContext:(CGContextRef)destContext {
    objc_setAssociatedObject(self, @selector(destContext), (__bridge id _Nullable)(destContext), OBJC_ASSOCIATION_ASSIGN);
}

- (CGContextRef)destContext {
    return (__bridge CGContextRef)(objc_getAssociatedObject(self, _cmd));
}

- (void)setLoaded:(BOOL)loaded {
    objc_setAssociatedObject(self, @selector(loaded), [NSNumber numberWithBool:loaded], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)loaded {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
