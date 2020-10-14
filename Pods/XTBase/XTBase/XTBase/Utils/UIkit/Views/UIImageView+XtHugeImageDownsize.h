//
//  UIImageView+XtHugeImageDownsize.h
//  XTBase
//
//  Created by teason23 on 2020/8/13.
//  Copyright © 2020 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (XtHugeImageDownsize)
// 大图逐行绘制一张缩略图, 适合超大图第一次生成缩略图
- (void)xt_hugeImageDownsize:(UIImage *)image
            renderCompletion:(void(^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
