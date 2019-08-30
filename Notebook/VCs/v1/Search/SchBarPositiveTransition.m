//
//  SchBarPositiveTransition.m
//  Notebook
//
//  Created by teason23 on 2019/4/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SchBarPositiveTransition.h"
#import "OcHomeVC.h"

static const float kDuration_animate_1 = .3 ;
static const float kDuration_animate_2 = .2 ;

@implementation SchBarPositiveTransition


- (instancetype)initWithPositive:(BOOL)isPositive {
    self = [super init];
    if (self) {
        _isPositive = isPositive ;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPositive) {
        return  kDuration_animate_1 + kDuration_animate_2 ;
    }
    else {
        return kDuration_animate_1 + kDuration_animate_2 + kDuration_animate_1 ;
    }
    
    return 0 ;
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

- (CGFloat)myWidth {
    return APP_WIDTH ;
}

- (void)positiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    OcHomeVC *fromVC = (OcHomeVC *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] ;
    UINavigationController *toVC   = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] ;
    UIView *containerView = [transitionContext containerView] ;
    
    UIView *ssImage = [fromVC.btSearch snapshotViewAfterScreenUpdates:NO] ;
    fromVC.btSearch.hidden = YES ;
    ssImage.frame = self.originRect_img = [containerView convertRect:fromVC.btSearch.frame fromView:fromVC.btSearch.superview] ;
    
    UIView *ssBar = [UIView new] ;
    ssBar.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_backColor) ; //[UIColor whiteColor] ;

    ssBar.frame = self.originRect_bar = CGRectMake(0, 0, APP_WIDTH, 69) ;
    
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC] ;
    toVC.view.alpha = 0 ;
    
    
    // 把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:ssBar] ;
    [containerView addSubview:toVC.view] ;
    [containerView addSubview:ssImage] ;
    
    
    [containerView layoutIfNeeded] ;
    [UIView animateWithDuration:kDuration_animate_1 + kDuration_animate_2 animations:^{
        
        ssBar.frame = APPFRAME ;
        fromVC.view.alpha = 0 ;
   
        ssImage.frame = CGRectMake(15+10, 10 + APP_STATUSBAR_HEIGHT + 11, 21, 21) ;
        ssImage.alpha = .6 ;
        toVC.view.alpha = 1.0 ;
        
    }
                     completion:^(BOOL finished) {
                         
                         fromVC.btSearch.hidden = NO ;
                         
                         [ssImage removeFromSuperview] ;
                         [ssBar removeFromSuperview] ;
                         
                         fromVC.view.alpha = 1 ;
                         
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled] ;
    
                     }] ;
}





- (void)negativeTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    OcHomeVC *fromVC = (OcHomeVC *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] ;
    UINavigationController *toVC   = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] ;

    UIView *containerView = [transitionContext containerView] ;
    
    
    UIView *ssImage = [fromVC.btSearch snapshotViewAfterScreenUpdates:NO] ;
    ssImage.alpha = .6 ;
    fromVC.btSearch.hidden = YES ;
    ssImage.frame = CGRectMake(15+10, 10 + APP_STATUSBAR_HEIGHT + 11, 21, 21) ;
    
    UIView *backView = [toVC.view snapshotViewAfterScreenUpdates:NO] ;
    
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC] ;
    toVC.view.hidden = YES ;
    
    // 把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:backView] ;
    [containerView addSubview:ssImage] ;
    
    [UIView animateWithDuration:kDuration_animate_1 animations:^{
        backView.alpha = 0 ;
        
    } completion:^(BOOL finished) {
        
        [backView removeFromSuperview] ;
        
        [UIView animateWithDuration:(kDuration_animate_2 + kDuration_animate_1 ) animations:^{
            ssImage.frame = self.originRect_img ;
        } completion:^(BOOL finished) {
            
            [ssImage removeFromSuperview] ;
            
            fromVC.btSearch.hidden = NO ;
            toVC.view.hidden = NO ;
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled] ;
        
        }] ;

    }] ;
    
}


@end
