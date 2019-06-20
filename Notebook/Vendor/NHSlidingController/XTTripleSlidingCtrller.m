//
//  XTTripleSlidingCtrller.m
//  Notebook
//
//  Created by teason23 on 2019/6/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTTripleSlidingCtrller.h"
#import <QuartzCore/QuartzCore.h>
#import <XTlib/XTlib.h>
#import "AppDelegate.h"
#import "MDThemeConfiguration.h"
#import "UIViewController+SlidingController.h"



// Standard speed for the sliding in pt/s
static const CGFloat slidingSpeed = 800 ;


@interface XTTripleSlidingCtrller ()
@property (nonatomic, strong) UITapGestureRecognizer    *tapGestureRecognizer;
@property (nonatomic, strong) UIView                    *topViewContainer;
@property (nonatomic, strong) UIView                    *midViewContainer;
@property (nonatomic, strong) UIView                    *bottomViewContainer;
@property (nonatomic)         CGSize                    m_containerSize;
@property (nonatomic)         BOOL                      drawerOpened;
@end

@implementation XTTripleSlidingCtrller

- (id)initWithTopViewController:(UIViewController *)topViewController
              midViewController:(UIViewController *)midViewController
           bottomViewController:(UIViewController *)bottomViewController
                    fstDistance:(float)fstDistance
                    secDistance:(float)secDistance {
    
    self = [super init] ;
    if (self) {
        self.topViewController = topViewController ;
        self.midViewController = midViewController ;
        self.bottomViewController = bottomViewController ;
        self.fstDistance = fstDistance ;
        self.secDistance = secDistance ;
        self.view.backgroundColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
    }
    return self ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
    [self setupTheViewWithSize:appDelegate.window.size] ;
    
    [self setupTheGestureRecognizers] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning] ;
}

- (void)setupTheViewWithSize:(CGSize)size {
    self.m_containerSize = size ;
    float w = size.width ;
    float h = size.height ;
    CGRect rect = CGRectMake(0, 0, w, h) ;
    NSValue *val = [NSValue valueWithCGSize:size] ;
    
    if (_bottomViewContainer.subviews) {
        for (UIView *subView in _bottomViewContainer.subviews) [subView removeFromSuperview] ;
        [_bottomViewContainer removeFromSuperview] ;
        _bottomViewContainer = nil ;
    }
    if (_midViewContainer.subviews) {
        for (UIView *subView in _midViewContainer.subviews) [subView removeFromSuperview] ;
        [_midViewContainer removeFromSuperview] ;
        _midViewContainer = nil ;
    }
    if (_topViewContainer.subviews) {
        for (UIView *subView in _topViewContainer.subviews) [subView removeFromSuperview] ;
        [_topViewContainer removeFromSuperview] ;
        _topViewContainer = nil ;
    }
    
    self.view.frame = rect ;
    
    _bottomViewContainer = [[UIView alloc] initWithFrame:rect];
    _bottomViewContainer.center = self.view.center ;
    _bottomViewContainer.width = self.fstDistance ;
    _bottomViewContainer.height = h ;
    [self.view addSubview:_bottomViewContainer];
    [self.view sendSubviewToBack:_bottomViewContainer];
    
    _midViewContainer = [[UIView alloc] initWithFrame:rect];
    _midViewContainer.center = self.view.center ;
    _midViewContainer.width = self.secDistance ;
    _midViewContainer.height = h ;
    [self.view addSubview:_midViewContainer] ;
    
    _topViewContainer = [[UIView alloc] initWithFrame:rect];
    _topViewContainer.center = self.view.center ;
    _topViewContainer.width = w ;
    _topViewContainer.height = h ;
    [self.view addSubview:_topViewContainer];
    [self.view bringSubviewToFront:_topViewContainer];
    
    _bottomViewController.view.frame = _bottomViewContainer.bounds ;
    [_bottomViewContainer addSubview:_bottomViewController.view];
    [self.view sendSubviewToBack:_bottomViewContainer];
    _bottomViewController.slidingController = self;
    
    _midViewController.view.frame = _midViewContainer.bounds ;
    [_midViewContainer addSubview:_midViewController.view];
    _midViewController.slidingController = self;
    
    _topViewController.view.clipsToBounds = YES ;
    _topViewController.view.frame = _topViewContainer.bounds ;
    [_topViewContainer addSubview:_topViewController.view] ;
    [self.view bringSubviewToFront:_topViewContainer];
    _topViewController.slidingController = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteSlidingSizeChanging object:val] ;
}

- (void)resetSize:(CGSize)size {
    self.m_containerSize = size ;
    float w = size.width ;
    float h = size.height ;
    
    _bottomViewContainer.width = self.fstDistance ;
    _bottomViewContainer.height = h ;
    
    _midViewContainer.width = self.secDistance ;
    _midViewContainer.height = h ;
    
    _topViewContainer.height = h ;
    _topViewContainer.width = _drawerOpened ? w - self.fstDistance - self.secDistance : w ;
    
    //    [self.view setNeedsLayout] ;
    //    [self.view layoutIfNeeded] ;
}

- (void)setupTheGestureRecognizers {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
    _tapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}


#pragma mark - UIGestureRecognizerDelegate

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
//        CGPoint translation = [panGestureRecognizer translationInView:self.view];
//        BOOL directionIsHorizontal = (fabs(translation.x) > fabs(translation.y));
//        BOOL directionIsToRight = translation.x > 0;
//        return directionIsHorizontal && (directionIsToRight || self.drawerOpened);
//    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
//        return [tapRecognizer locationInView:self.view].x > self.slideDistance;
//    }
//    
//    return YES;
//}
//
//- (void)panned:(UIPanGestureRecognizer *)recognizer {
//    CGFloat translation = [recognizer translationInView:self.view].x;
//    [recognizer setTranslation:CGPointZero inView:self.view];
//    NSLog(@"x : %lf",translation) ;
//    float openedLeft = self.slideDistance ;
//    float left = _topViewContainer.left ;
//    left = left < openedLeft ? left + translation : left + translation / (1. + left - openedLeft) ;
//    self->_topViewContainer.width = self.m_containerSize.width - left ;
//    self->_topViewContainer.left = left ;
//
//    if (recognizer.state != UIGestureRecognizerStateEnded) return ;
//
//    CGFloat leftForEdge, leftForBounce;
//    BOOL finalOpenState;
//    CGFloat velocity = [recognizer velocityInView:self.view].x;
//
//    if (velocity > 0) {
//        leftForEdge = self.slideDistance;
//        leftForBounce = leftForEdge + 22.0;
//        finalOpenState = YES;
//    }
//    else {
//        leftForEdge = 0;
//        leftForBounce = leftForEdge - 22.0;
//        finalOpenState = NO;
//    }
//
//    CGFloat distanceToTheEdge = leftForEdge - _topViewContainer.left;
//    CGFloat timeToEdgeWithCurrentVelocity = fabs(distanceToTheEdge) / fabs(velocity);
//    CGFloat timeToEdgeWithStandardVelocity = fabs(distanceToTheEdge) / slidingSpeed;
//    if (timeToEdgeWithCurrentVelocity < 0.7 * timeToEdgeWithStandardVelocity) {
//        //Bounce and open
//        left = leftForBounce;
//
//        [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self->_topViewContainer.left = left;
//        } completion:^(BOOL finished) {
//            CGFloat left = self->_topViewContainer.left;
//            left = leftForEdge;
//            [UIView animateWithDuration:0.3 animations:^{
//                self->_topViewContainer.width = self.m_containerSize.width - left ;
//                self->_topViewContainer.left = left;
//            } completion:^(BOOL finished) {
//                self.drawerOpened = finalOpenState;
//            }];
//        }];
//    }
//    else if (timeToEdgeWithCurrentVelocity < timeToEdgeWithStandardVelocity) {
//        //finish the sliding with the current speed
//        left = leftForEdge;
//
//        [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self->_topViewContainer.width = self.m_containerSize.width - left ;
//            self->_topViewContainer.left = left;
//        } completion:^(BOOL finished) {
//            self.drawerOpened = finalOpenState;
//        }];
//    }
//    else {
//        //finish the sliding wiht minimum speed
//        CGFloat duration = distanceToTheEdge / slidingSpeed;
//        left = leftForEdge;
//        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self->_topViewContainer.width = self.m_containerSize.width - left ;
//            self->_topViewContainer.left = left;
//        } completion:^(BOOL finished) {
//            self.drawerOpened = finalOpenState;
//        }];
//    }
//}
//
//- (void)tapped:(UITapGestureRecognizer *)tapGestureRecognizer {
////    [self toggleDrawer];
//}











#pragma mark - add test
#pragma mark Size Class Related

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    NSLog(@"traitCollectionDidChange: previous %@, new %@", [[self class] sizeClassInt2Str:previousTraitCollection.horizontalSizeClass],
          [[self class] sizeClassInt2Str:self.traitCollection.horizontalSizeClass]);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    NSLog(@"willTransitionToTraitCollection: current %@, new: %@",
          [[self class] sizeClassInt2Str:self.traitCollection.horizontalSizeClass],
          [[self class] sizeClassInt2Str:newCollection.horizontalSizeClass]) ;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    NSLog(@"viewWillTransitionToSize: size %@", NSStringFromCGSize(size)) ;
//    [self resetSize:size] ;
//    NSValue *val = [NSValue valueWithCGSize:size] ;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteSlidingSizeChanging object:val] ;
}

#pragma mark -
+ (NSString*)sizeClassInt2Str:(UIUserInterfaceSizeClass)sizeClass {
    switch (sizeClass) {
        case UIUserInterfaceSizeClassCompact:
            return @"UIUserInterfaceSizeClassCompact";
        case UIUserInterfaceSizeClassRegular:
            return @"UIUserInterfaceSizeClassRegular";
        case UIUserInterfaceSizeClassUnspecified:
        default:
            return @"UIUserInterfaceSizeClassUnspecified";
    }
}

@end
