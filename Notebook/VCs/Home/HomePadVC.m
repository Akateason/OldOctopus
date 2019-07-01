//
//  HomePadVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomePadVC.h"
#import "HomeVC.h"
#import "LeftDrawerVC.h"
#import "NHSlidingController.h"
#import "UIViewController+SlidingController.h"
#import "GlobalDisplaySt.h"


const float kWidth_ListView = 320 ;
static const float slidingSpeed = 2000 ;

@interface HomePadVC ()
@property (strong, nonatomic) UIView        *leftContainer ;
@property (strong, nonatomic) UIView        *rightContainer ;
@property (strong, nonatomic) HomeVC        *homeVC ;
@property (nonatomic) CGSize containerSize ;
@end

@implementation HomePadVC

+ (UIViewController *)getMe {
    HomePadVC *hPadVC = [HomePadVC new] ;
    LeftDrawerVC *leftVC = [LeftDrawerVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"LeftDrawerVC"];
    
    hPadVC.homeVC.leftVC = leftVC ;
    NHSlidingController *slidingController = [[NHSlidingController alloc] initWithTopViewController:hPadVC bottomViewController:leftVC slideDistance:HomeVC.movingDistance] ;
    hPadVC.editorVC.oct_panDelegate = (id<MarkdownVCPanGestureDelegate>)slidingController ;
    hPadVC.editorVC.pad_panDelegate = (id<MDVC_PadVCPanGestureDelegate>)hPadVC ;
    hPadVC.homeVC.slidingController = slidingController ;
    hPadVC.slidingController = slidingController ;
    leftVC.slidingController = slidingController ;
    return slidingController ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
        _editorVC = [MarkdownVC newWithNote:nil bookID:nil fromCtrller:_homeVC] ;        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    _leftContainer = [UIView new] ;
    _leftContainer.width = kWidth_ListView ;
    _leftContainer.height = self.view.height ;
    _leftContainer.left = self.view.left ;
    _leftContainer.top = self.view.top ;
    _leftContainer.bottom = self.view.bottom ;
    [self.view addSubview:_leftContainer] ;
    
    _rightContainer = [UIView new] ;
    _rightContainer.width = APP_WIDTH ;
    _rightContainer.height = self.view.height ;
    _rightContainer.left = kWidth_ListView ;
    _rightContainer.top = self.view.top ;
    _rightContainer.bottom = self.view.bottom ;
    [self.view addSubview:_rightContainer] ;
    
    _homeVC.view.frame = _leftContainer.bounds ;
    [_leftContainer addSubview:_homeVC.view] ;
    _editorVC.view.frame = _rightContainer.bounds ;
    [_rightContainer addSubview:_editorVC.view] ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNoteSlidingSizeChanging object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        NSValue *val = x.object ;
        self.containerSize = [val CGSizeValue] ;
        
        self.leftContainer.width = kWidth_ListView ;
        self.leftContainer.height = self.view.height ;
        self.leftContainer.left = self.view.left ;
        self.leftContainer.top = self.view.top ;
        self.leftContainer.bottom = self.view.bottom ;
        
        self.rightContainer.width = self.containerSize.width ;
        self.rightContainer.height = self.view.height ;
        self.rightContainer.left = kWidth_ListView ;
        self.rightContainer.top = self.view.top ;
        self.rightContainer.bottom = self.view.bottom ;
        
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1) {
            self.rightContainer.left = 0 ;
        }
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_ClickNote_In_Pad object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        Note *note = x.object ;
        [self.editorVC setupWithNote:note bookID:note.noteBookId fromCtrller:self.homeVC] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_pad_Editor_OnClick object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == 1) {
            [self.slidingController toggleDrawer] ;
            [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = 0 ;
            return ;
        }
        
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = -1;
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.rightContainer.left = 0 ;
            [self moveEmptyView:YES] ;
            [self setupLeftForRightVC:-1] ;
        } completion:^(BOOL finished) {
            
        }] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_pad_Editor_PullBack object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = 0;
        
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.rightContainer.left = kWidth_ListView ;
            [self moveEmptyView:NO] ;
            [self setupLeftForRightVC:0] ;
        } completion:^(BOOL finished) {
            
        }] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_new_Note_In_Pad object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = -1;
        
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.rightContainer.left = 0 ;
            [self moveEmptyView:YES] ;
        } completion:^(BOOL finished) {
            [self.editorVC setupWithNote:nil bookID:nil fromCtrller:self.homeVC] ;
        }] ;
    }] ;
}

#pragma mark - MDVC_PadVCPanGestureDelegate <NSObject>

- (void)pad_panned:(UIPanGestureRecognizer *)recognizer {
    CGFloat translation = [recognizer translationInView:self.view].x;
    [recognizer setTranslation:CGPointZero inView:self.view];
    
//    NSLog(@"pad_panned : %lf",translation) ;
    float openedLeft = 0 ;
    float left = _rightContainer.left ;
    left = left < openedLeft ? left + translation : left + translation / (1. + left - openedLeft) ;
    self->_rightContainer.left = left ;
    
    if (recognizer.state != UIGestureRecognizerStateEnded) return ;

    CGFloat leftForEdge, leftForBounce;
    int finalOpenState;
    CGFloat velocity = [recognizer velocityInView:self.view].x;

    if (velocity > 0) {
        leftForEdge = kWidth_ListView;
        leftForBounce = leftForEdge + 22.0;
        finalOpenState = 0;
    }
    else {
        leftForEdge = 0;
        leftForBounce = leftForEdge - 22.0;
        finalOpenState = -1;
        
        if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == 1) {
            [self.slidingController toggleDrawer] ;
            return ;
        }
    }

    CGFloat distanceToTheEdge = leftForEdge - _rightContainer.left;
    CGFloat timeToEdgeWithCurrentVelocity = fabs(distanceToTheEdge) / fabs(velocity);
    CGFloat timeToEdgeWithStandardVelocity = fabs(distanceToTheEdge) / slidingSpeed;
    if (timeToEdgeWithCurrentVelocity < 0.7 * timeToEdgeWithStandardVelocity) {
        //Bounce and open
        left = leftForBounce ;
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = finalOpenState ;
        
        [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self->_rightContainer.left = left;
            [self moveEmptyView:finalOpenState == -1] ;
        } completion:^(BOOL finished) {
            CGFloat left = self->_rightContainer.left;
            left = leftForEdge;
            [UIView animateWithDuration:0.3 animations:^{
                self->_rightContainer.left = left;
                [self moveEmptyView:finalOpenState == -1] ;
                [self setupLeftForRightVC:finalOpenState] ;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    else if (timeToEdgeWithCurrentVelocity < timeToEdgeWithStandardVelocity) {
        //finish the sliding with the current speed
        left = leftForEdge;
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = finalOpenState;
        
        [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self->_rightContainer.left = left;
            [self moveEmptyView:finalOpenState == -1] ;
            [self setupLeftForRightVC:finalOpenState] ;
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        //finish the sliding wiht minimum speed
        CGFloat duration = distanceToTheEdge / slidingSpeed;
        left = leftForEdge;
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = finalOpenState;
        
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self->_rightContainer.left = left;
            [self moveEmptyView:finalOpenState == -1] ;
            [self setupLeftForRightVC:finalOpenState] ;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)setupLeftForRightVC:(int)finalOpenState {
    float left = finalOpenState != -1 ? (- [GlobalDisplaySt sharedInstance].containerSize.width / 4. + 28.) : 0 ;
    _editorVC.editor.left = left ;
}

- (void)moveEmptyView:(BOOL)stateOn {
    if (stateOn) {
        self.editorVC.emptyView.center = self.editorVC.view.center ;
    }
    else {
        self.editorVC.emptyView.left = self.editorVC.view.left ;
    }
}

@end
