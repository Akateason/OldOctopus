//
//  SchBarPositiveTransition.m
//  Notebook
//
//  Created by teason23 on 2019/4/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SchBarPositiveTransition.h"
#import "HomeVC.h"
#import "HomeSearchCell.h"



@implementation SchBarPositiveTransition

- (instancetype)initWithPositive:(BOOL)isPositive {
    self = [super init];
    if (self) {
        _isPositive = isPositive ;
    }
    return self;
}


- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return  .2 + .4 ;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPositive) {
        [self positiveTransition:transitionContext] ;
    }
    else {
        [self negativeTransition:transitionContext] ;
    }
}


- (void)positiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    HomeVC *fromVC = (HomeVC *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] ;
    UINavigationController *toVC   = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] ;
    UIView *containerView = [transitionContext containerView] ;
    
    HomeSearchCell *lCell = (HomeSearchCell *)[fromVC.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] ;
    
    UIView *ssImage = [lCell.imgSearchIcon snapshotViewAfterScreenUpdates:NO] ;
    lCell.imgSearchIcon.hidden = YES ;
    ssImage.frame = self.originRect_img = [containerView convertRect:lCell.imgSearchIcon.frame fromView:lCell.imgSearchIcon.superview] ;
    
    UIView *ssLabelText = [lCell.lbPh snapshotViewAfterScreenUpdates:YES] ;
    lCell.lbPh.hidden = YES ;
    ssLabelText.frame = self.originRect_text = [containerView convertRect:lCell.lbPh.frame fromView:lCell.lbPh.superview] ;
    
    UIView *ssBar = [lCell.scBar snapshotViewAfterScreenUpdates:YES] ;
    lCell.scBar.hidden = YES ;
    ssBar.frame = self.originRect_bar = [containerView convertRect:lCell.scBar.frame fromView:lCell.scBar.superview] ;
    
    BOOL isDarkMode = [[MDThemeConfiguration sharedInstance].currentThemeKey containsString:@"Dark"] ;
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight] ;
    UIVisualEffectView *backView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct] ;
    backView.frame = self.originRect_cell = [containerView convertRect:lCell.frame fromView:lCell.superview] ;
    
    lCell.hidden = YES ;
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC] ;
    toVC.view.alpha = 0 ;
    
    
    // 把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:toVC.view] ;
    [containerView addSubview:backView] ;
    [containerView addSubview:ssBar] ;
    [containerView addSubview:ssImage] ;
    [containerView addSubview:ssLabelText] ;
    
    
    [UIView animateWithDuration:.2 animations:^{
        [containerView layoutIfNeeded] ;
        backView.frame = APPFRAME ;
    }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              toVC.view.alpha = 1.0 ;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              lCell.lbPh.hidden = NO ;
                                              lCell.scBar.hidden = NO ;
                                              lCell.imgSearchIcon.hidden = NO ;
                                              lCell.hidden = NO ;
                                              
                                          }] ;
                         
                         
                         [UIView animateWithDuration:.4 animations:^{
                             
                             ssBar.frame = CGRectMake(15, 10 + APP_STATUSBAR_HEIGHT, APP_WIDTH - 15 - 74, 38) ;
                             ssImage.frame = CGRectMake(15+10, 10 + APP_STATUSBAR_HEIGHT + 11, 16, 16) ;
                             ssLabelText.frame = CGRectMake(15+10+26, 10 + APP_STATUSBAR_HEIGHT + 9, ssLabelText.frame.size.width, ssLabelText.frame.size.height) ;
                             
                         } completion:^(BOOL finished) {
                             
                             [backView removeFromSuperview] ;
                             [ssBar removeFromSuperview] ;
                             [ssImage removeFromSuperview] ;
                             [ssLabelText removeFromSuperview] ;
                             
                             
                             [transitionContext completeTransition:!transitionContext.transitionWasCancelled] ;
                             
                         }] ;
                         
                     }] ;
}

- (void)negativeTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    HomeVC *fromVC = (HomeVC *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] ;
    UINavigationController *toVC   = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] ;

    UIView *containerView = [transitionContext containerView] ;
    
    HomeSearchCell *lCell = (HomeSearchCell *)[fromVC.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] ;
    
    UIView *ssImage = [lCell.imgSearchIcon snapshotViewAfterScreenUpdates:NO] ;
    lCell.imgSearchIcon.hidden = YES ;
    ssImage.frame = CGRectMake(15+10, 10 + APP_STATUSBAR_HEIGHT + 11, 16, 16) ;
    
    UIView *ssLabelText = [lCell.lbPh snapshotViewAfterScreenUpdates:YES] ;
    lCell.lbPh.hidden = YES ;
    ssLabelText.frame = CGRectMake(15+10+26, 10 + APP_STATUSBAR_HEIGHT + 9, ssLabelText.frame.size.width, ssLabelText.frame.size.height) ;
    
    UIView *ssBar = [lCell.scBar snapshotViewAfterScreenUpdates:YES] ;
    lCell.scBar.hidden = YES ;
    ssBar.frame = CGRectMake(15, 10 + APP_STATUSBAR_HEIGHT, APP_WIDTH - 15 - 74, 38) ;
    
    BOOL isDarkMode = [[MDThemeConfiguration sharedInstance].currentThemeKey containsString:@"Dark"] ;
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight] ;
    UIVisualEffectView *backView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct] ;
    backView.frame = APPFRAME ;
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC] ;
    toVC.view.hidden = YES ;
    
    // 把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:backView] ;
    [containerView addSubview:ssBar] ;
    [containerView addSubview:ssImage] ;
    [containerView addSubview:ssLabelText] ;
    
     [UIView animateWithDuration:.6 animations:^{
         backView.frame = self.originRect_cell ;
         ssBar.frame = self.originRect_bar ;
         ssImage.frame = self.originRect_img ;
         ssLabelText.frame = self.originRect_text ;
         
     } completion:^(BOOL finished) {
         
         [backView removeFromSuperview] ;
         [ssBar removeFromSuperview] ;
         [ssImage removeFromSuperview] ;
         [ssLabelText removeFromSuperview] ;
         
         lCell.lbPh.hidden = NO ;
         lCell.scBar.hidden = NO ;
         lCell.imgSearchIcon.hidden = NO ;
         toVC.view.hidden = NO ;
         
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled] ;
     }] ;
                         
    
}


@end
