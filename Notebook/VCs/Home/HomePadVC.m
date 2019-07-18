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
    slidingController.animateDelegate = hPadVC.editorVC ;
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
    
    self.view.xt_theme_backgroundColor = k_md_drawerColor ;
    
    _leftContainer = [UIView new] ;
    _leftContainer.width = kWidth_ListView ;
    _leftContainer.height = self.view.height ;
    _leftContainer.left = self.view.left ;
    _leftContainer.top = APP_STATUSBAR_HEIGHT ;
    _leftContainer.bottom = self.view.bottom ;
    [self.view addSubview:_leftContainer] ;
    
    _rightContainer = [UIView new] ;
    _rightContainer.width = APP_WIDTH ;
    _rightContainer.height = self.view.height ;
    _rightContainer.left = kWidth_ListView ;
    _rightContainer.top = APP_STATUSBAR_HEIGHT ;
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
        self.leftContainer.top = APP_STATUSBAR_HEIGHT ;
        self.leftContainer.bottom = self.view.bottom ;
        
        self.rightContainer.width = self.containerSize.width ;
        self.rightContainer.height = self.view.height ;
        self.rightContainer.left = kWidth_ListView ;
        self.rightContainer.top = APP_STATUSBAR_HEIGHT ;
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
            [self.slidingController setDrawerOpened:NO animated:YES] ;
            [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = 0 ;
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
        
        [self.slidingController setDrawerOpened:NO animated:YES] ;
        [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = -1;
        
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.rightContainer.left = 0 ;
            [self moveEmptyView:YES] ;
            [self.editorVC setupWithNote:nil bookID:nil fromCtrller:self.homeVC] ;
            self.editorVC.editor.left = 0 ;
        } completion:^(BOOL finished) {
            
        }] ;
    }] ;
    
}

#pragma mark - MDVC_PadVCPanGestureDelegate <NSObject>

- (void)pad_panned:(UIPanGestureRecognizer *)recognizer {
    
    
    CGPoint offset = [recognizer translationInView:self.view] ;
    if (fabs(offset.y) > fabs(offset.x) && recognizer.state == UIGestureRecognizerStateBegan) return ;
    NSLog(@"11111 ") ;
    
    CGFloat translation = offset.x;
    CGFloat velocity = [recognizer velocityInView:self.view].x ;
//    if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 &&
//        velocity < 0
//         && (recognizer.state != UIGestureRecognizerStateChanged )
//        ) {
//        return ;
//    }
    
    float openedLeft = 0 ;
    float left = _rightContainer.left ;
    left = left < openedLeft ? left + translation : left + translation / (1. + left - openedLeft) ;
//    left = left < 0 ? 0 : left ;
    NSLog(@"velocity : %lf\n offset : %@\nleft : %lf",velocity,NSStringFromCGPoint(offset),left) ;
    if (left < 0) return ;
    
    self->_rightContainer.left = left ;
    [recognizer setTranslation:CGPointZero inView:self.view] ;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat leftForEdge, leftForBounce;
        int finalOpenState ;
        NSLog(@"2222222") ;
        if (velocity > 0) {
            leftForEdge = kWidth_ListView;
            leftForBounce = leftForEdge + 22.0;
            finalOpenState = 0;

            // pad ,里面, 左滑, 安全距离
            if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == -1 && velocity > 0 && velocity < 300 && left < 100) {
                self->_rightContainer.left = 0 ;
                NSLog(@"33333333");
                return ;
            }
        }
        else {
            leftForEdge = 0;
            leftForBounce = leftForEdge - 22.0;
            finalOpenState = -1;

            if ([GlobalDisplaySt sharedInstance].gdst_level_for_horizon == 1) {
                [self.slidingController setDrawerOpened:NO animated:YES] ;
                NSLog(@"4444444");
                return ;
            }
        }
        
        NSLog(@"555555") ;
        
        if (finalOpenState == 0) { //手势, 更新文章
            [_editorVC leaveOut] ;
        }
        
        CGFloat distanceToTheEdge = leftForEdge - _rightContainer.left;
        CGFloat timeToEdgeWithCurrentVelocity = fabs(distanceToTheEdge) / fabs(velocity);
        CGFloat timeToEdgeWithStandardVelocity = fabs(distanceToTheEdge) / slidingSpeed;
        if (timeToEdgeWithCurrentVelocity < 0.7 * timeToEdgeWithStandardVelocity) {
            //Bounce and open
            left = leftForBounce ;
            
            [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self->_rightContainer.left = left;
                [self moveEmptyView:finalOpenState == -1] ;
            } completion:^(BOOL finished) {
                CGFloat left = self->_rightContainer.left;
                left = leftForEdge;
                
                [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = finalOpenState ;
                
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
            
            [UIView animateWithDuration:timeToEdgeWithCurrentVelocity delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self->_rightContainer.left = left;
                [self moveEmptyView:finalOpenState == -1] ;
                [self setupLeftForRightVC:finalOpenState] ;
            } completion:^(BOOL finished) {
                [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = finalOpenState;
            }];
        }
        else {
            //finish the sliding wiht minimum speed
            CGFloat duration = distanceToTheEdge / slidingSpeed;
            left = leftForEdge;
            
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self->_rightContainer.left = left;
                [self moveEmptyView:finalOpenState == -1] ;
                [self setupLeftForRightVC:finalOpenState] ;
            } completion:^(BOOL finished) {
                [GlobalDisplaySt sharedInstance].gdst_level_for_horizon = finalOpenState;
            }];
        }
    }
}

- (void)setupLeftForRightVC:(int)finalOpenState {
    float left = finalOpenState != -1 ? ([MarkdownVC getEditorLeftIpad]) : 0 ;
    _editorVC.editor.left = left ;
}

- (void)moveEmptyView:(BOOL)stateOn {
    if (stateOn) {
        self.editorVC.emptyView.center = self.editorVC.view.center ;
    }
    else {
//        [GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView - HomeVC.movingDistance ;
        float newWid = ([GlobalDisplaySt sharedInstance].containerSize.width - kWidth_ListView) / 2. ;
        self.editorVC.emptyView.centerX = newWid ;
    }
}

@end
