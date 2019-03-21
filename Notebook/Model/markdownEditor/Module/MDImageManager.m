//
//  MDImageManager.m
//  Notebook
//
//  Created by teason23 on 2019/3/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDImageManager.h"
#import <SDWebImage/SDWebImageManager.h>

@interface MDImageManager ()

@end

@implementation MDImageManager
XT_SINGLETON_M(MDImageManager)

- (UIImage *)imagePlaceHolder {
    return [UIImage imageNamed:@"test"] ;
}

- (void)imageWithUrlStr:(NSString *)urlStr
               complete:(void(^)(UIImage *image))complete {
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlStr] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!error) {
            complete(image) ;
        }
    }] ;
}

@end
