//
//  UIView+OctupusExtension.h
//  Notebook
//
//  Created by teason23 on 2019/4/18.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (OctupusExtension)

- (void)oct_addBlurBg ;

- (void)oct_buttonClickAnimationComplete:(void(^)(void))completion ;
- (void)oct_buttonClickAnimationWithScale:(float)scale
                                 complete:(void(^)(void))completion ;


@end

NS_ASSUME_NONNULL_END
