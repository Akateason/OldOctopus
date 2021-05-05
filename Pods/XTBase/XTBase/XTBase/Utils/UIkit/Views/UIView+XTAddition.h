//
//  UIView+XTAddition.h
//  XTkit
//
//  Created by xtc on 2018/2/5.
//  Copyright © 2018年 teason. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (XTAddition)
+ (UIWindow *)xt_topWindow;
+ (CGRect)currentScreenBoundsDependOnOrientation ;
// tap self to hide keyboard
- (void)xt_resignAllResponderWhenTapThis;
@end


@interface UIView (CurrentController)
@property (strong, nonatomic, readwrite) UIViewController       *xt_viewController;
@property (strong, nonatomic, readwrite) UINavigationController *xt_navigationController;
- (NSString *)xt_chainInfo;
@end


@interface UIView (MakeScollView)
- (UIScrollView *)xt_wrapperWithScrollView;
- (UIScrollView *)xt_wrapperWithHorizontalScrollView;
@end


@interface UIView (XTNib)
+ (instancetype)xt_newFromNib;
+ (instancetype)xt_newFromNibByBundle:(NSBundle *)bundle;
@end


@interface UIView (XTTouchEvent)
- (void)xt_whenTouches:(NSUInteger)numberOfTouches
                tapped:(NSUInteger)numberOfTaps
               handler:(void (^)(void))block ;

- (void)xt_whenTapped:(void (^)(void))block ;
- (void)xt_whenDoubleTapped:(void (^)(void))block ;
@end
