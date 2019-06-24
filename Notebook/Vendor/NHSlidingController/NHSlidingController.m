//
//  NHSlidingController.m
//  sliding
//
//  Created by Nils Hayat on 1/15/13.
//  Copyright (c) 2013 Nils Hayat. All rights reserved.
//

#import "NHSlidingController.h"
#import "UIViewController+SlidingController.h"
#import <QuartzCore/QuartzCore.h>
#import <XTlib/XTlib.h>
#import "AppDelegate.h"
#import "MDThemeConfiguration.h"
#import "MarkdownVC.h"
#import "GlobalDisplaySt.h"

#define SIZECLASS_2_STR(sizeClass) [[self class] sizeClassInt2Str:sizeClass]

// Standard speed for the sliding in pt/s
//static const CGFloat slidingSpeed = 800;
static const CGFloat slidingSpeed = 1500.0;

@interface NHSlidingController ()<MarkdownVCPanGestureDelegate> {
    UITapGestureRecognizer *tapGestureRecognizer;
}

@property (nonatomic, strong) UIView    *topViewContainer;
@property (nonatomic, strong) UIView    *bottomViewContainer;
@property (nonatomic)         CGSize    m_containerSize;
@property (nonatomic)         BOOL      drawerOpened;

@end

@implementation NHSlidingController

- (id)initWithTopViewController:(UIViewController *)topViewController
           bottomViewController:(UIViewController *)bottomViewController
                  slideDistance:(CGFloat)distance
{
    self = [super init];
    if (self) {
        self.topViewController = topViewController ;
        self.bottomViewController = bottomViewController ;
        self.slideDistance = distance ?: 200 ;
        self.view.xt_theme_backgroundColor = k_md_bgColor ;
    }
    return self; 
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
    [self setupTheViewWithSize:appDelegate.window.size] ;
    
    [self setupTheGestureRecognizers] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning] ;
}

#pragma mark - Setup Helpers

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
    if (_topViewContainer.subviews) {
        for (UIView *subView in _topViewContainer.subviews) [subView removeFromSuperview] ;
        [_topViewContainer removeFromSuperview] ;
        _topViewContainer = nil ;
    }
    
    self.view.frame = rect ;
    
    _bottomViewContainer = [[UIView alloc] initWithFrame:rect];
    _bottomViewContainer.center = self.view.center ;
    _bottomViewContainer.width = self.slideDistance ;
    _bottomViewContainer.height = h ;
    [self.view addSubview:_bottomViewContainer];
    [self.view sendSubviewToBack:_bottomViewContainer];
    
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
    
    _bottomViewContainer.width = self.slideDistance ;
    _bottomViewContainer.height = h ;
    
    _topViewContainer.height = h ;
    _topViewContainer.width = w ;
}

- (void)setupTheGestureRecognizers {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - Custom Accessors

- (void)setDrawerOpened:(BOOL)drawerOpened {
    _drawerOpened = drawerOpened;
    
    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon) {
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = drawerOpened ? 1 : 0 ;
    }
    
    if (drawerOpened) {
        _topViewContainer.userInteractionEnabled = NO;
        tapGestureRecognizer.enabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSlidingControllerDidOpenNotification object:self];
    }
    else {
        _topViewContainer.userInteractionEnabled = YES;
        tapGestureRecognizer.enabled = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSlidingControllerDidCloseNotification object:self];
    }
}

#pragma mark - Animation Trigger Methods

- (void)setTopViewController:(UIViewController *)topViewController animated:(BOOL)animated {
    if (!self.drawerOpened) {
        [self toggleDrawer];
    }
    
    if (animated) {
        CGRect frame = self.view.bounds;
        CGPoint centerForOutside = CGPointMake(frame.size.width * 1.5, CGRectGetMidY(frame));
        [UIView animateWithDuration:0.3 animations:^{
            self->_topViewContainer.center = centerForOutside;
        } completion:^(BOOL finished) {
            self.topViewController = topViewController;
            [self toggleDrawer];
        }];
    }
    else {
        self.topViewController = topViewController;
    }
}

- (void)setDrawerOpened:(BOOL)opened animated:(BOOL)animated {
    self.drawerOpened = opened ;
    
    CGFloat duration = self.slideDistance / slidingSpeed ;
    
//    if (opened) [self.bottomViewController viewWillAppear:YES];
//    [UIView animateWithDuration:duration animations:^{
//        self.topViewContainer.left = opened ? self.slideDistance : 0 ;
//        self.topViewContainer.width = opened ? self.m_containerSize.width - self.slideDistance : self.m_containerSize.width ;
//    }];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    if (opened) {
        center.x += self.slideDistance;
        [self.bottomViewController viewWillAppear:YES];
    }
    
    [UIView animateWithDuration:duration animations:^{
        self->_topViewContainer.center = center;
    }];
}

#pragma mark - Public Methods

- (void)toggleDrawer {
    [self setDrawerOpened:!_drawerOpened animated:YES];
}

-(void)openDrawerAnimated:(BOOL)animated {
    [self setDrawerOpened:YES animated:animated];
}


#pragma mark - MarkdownVCPanGestureDelegate <NSObject>

- (BOOL)oct_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [self gestureRecognizerShouldBegin:gestureRecognizer] ;
}

- (void)oct_panned:(UIPanGestureRecognizer *)recognizer {
    [self panned:recognizer] ;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        BOOL directionIsHorizontal = (fabs(translation.x) > fabs(translation.y));
        BOOL directionIsToRight = translation.x > 0;
        return directionIsHorizontal && (directionIsToRight || self.drawerOpened);
    } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
        return [tapRecognizer locationInView:self.view].x > self.slideDistance;
    }
    
    return YES;
}

- (void)panned:(UIPanGestureRecognizer *)recognizer {
	CGFloat translation = [recognizer translationInView:self.view].x;
    [recognizer setTranslation:CGPointZero inView:self.view];
    CGFloat openedWidthCenter = CGRectGetMidX(self.view.bounds) + self.slideDistance;
    
    CGPoint center = _topViewContainer.center;
    center.x = center.x < openedWidthCenter ? center.x + translation : center.x + translation / (1.0 + center.x - openedWidthCenter);
    center.x = MAX(center.x, CGRectGetMidX(self.view.bounds));
    _topViewContainer.center = center;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [recognizer velocityInView:self.view].x;
        
        CGFloat centerForEdge, centerForBounce;
        BOOL finalOpenState;
        if (velocity > 0) {
            centerForEdge = CGRectGetMidX(self.view.bounds) + self.slideDistance;
            centerForBounce = centerForEdge + 22.0;
            finalOpenState = YES;
        } else {
            centerForEdge = CGRectGetMidX(self.view.bounds);
            centerForBounce = (centerForEdge - 22.0);
            finalOpenState = NO;
        }
        
        CGFloat distanceToTheEdge = centerForEdge - _topViewContainer.center.x;
        CGFloat timeToEdgeWithCurrentVelocity = fabs(distanceToTheEdge) / fabs(velocity);
        CGFloat timeToEdgeWithStandardVelocity = fabs(distanceToTheEdge) / slidingSpeed;
        
        if (timeToEdgeWithCurrentVelocity < 0.7 * timeToEdgeWithStandardVelocity) {
            //Bounce and open
            center.x = centerForBounce;
            
            [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self->_topViewContainer.center = center;
            } completion:^(BOOL finished) {
                CGPoint center = self->_topViewContainer.center;
                center.x = centerForEdge;
                [UIView animateWithDuration:0.3 animations:^{
                    self->_topViewContainer.center = center;
                } completion:^(BOOL finished) {
                    self.drawerOpened = finalOpenState;
                }];
            }];
        } else if (timeToEdgeWithCurrentVelocity < timeToEdgeWithStandardVelocity) {
            //finish the sliding with the current speed
            center.x = centerForEdge;
            
            [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self->_topViewContainer.center = center;
            } completion:^(BOOL finished) {
                self.drawerOpened = finalOpenState;
            }];
        } else {
            //finish the sliding wiht minimum speed
            CGFloat duration = distanceToTheEdge / slidingSpeed;
            center.x = centerForEdge;
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self->_topViewContainer.center = center;
            } completion:^(BOOL finished) {
                self.drawerOpened = finalOpenState;
            }];
        }
    }    
}

- (void)tapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self toggleDrawer];
}





#pragma mark - add test
#pragma mark Size Class Related

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    NSLog(@"traitCollectionDidChange: previous %@, new %@", SIZECLASS_2_STR(previousTraitCollection.horizontalSizeClass), SIZECLASS_2_STR(self.traitCollection.horizontalSizeClass)) ;

}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    NSLog(@"willTransitionToTraitCollection: current %@, new: %@", SIZECLASS_2_STR(self.traitCollection.horizontalSizeClass), SIZECLASS_2_STR(newCollection.horizontalSizeClass)) ;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    NSLog(@"viewWillTransitionToSize: size %@", NSStringFromCGSize(size)) ;
    [self resetSize:size] ;
    NSValue *val = [NSValue valueWithCGSize:size] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteSlidingSizeChanging object:val] ;
    
    [[GlobalDisplaySt sharedInstance] correctCurrentCondition:self] ;
}


#pragma mark -
#pragma mark Helper Method

+ (NSString *)sizeClassInt2Str:(UIUserInterfaceSizeClass)sizeClass {
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
