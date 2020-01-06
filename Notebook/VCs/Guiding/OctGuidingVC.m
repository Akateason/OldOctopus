//
//  OctGuidingVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctGuidingVC.h"
#import "SingleGuidVC.h"
#import <XTlib/XTlib.h>
#import <EllipsePageControl/EllipsePageControl.h>
#import "MDThemeConfiguration.h"
#import "AppDelegate.h"
#import "MDNavVC.h"
#import "GlobalDisplaySt.h"
#import "OcHomeVC.h"

@interface OctGuidingVC () {
    long ld_currentIndex ;
    
}
@property (copy, nonatomic) NSArray *vcList ;
@property (nonatomic, strong) EllipsePageControl *pageCtrl ;
@end

@implementation OctGuidingVC



+ (instancetype)getMe {
    if (ISMAC) {
        return nil ;
    }
    
    //  小版本更新就更新
//    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
//    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
//    if ([currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending) return nil ;
    
    //  安装app第一次打开则更新
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
    if (versionCached != nil && versionCached.length > 0) {
        return nil ;
    }
    
    XT_USERDEFAULT_SET_VAL([CommonFunc getVersionStrOfMyAPP], kKey_markForGuidingDisplay) ;

    NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:UIPageViewControllerOptionInterPageSpacingKey] ;
    OctGuidingVC *pageVC = [[OctGuidingVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option] ;
    pageVC.view.xt_theme_backgroundColor = k_md_bgColor ;
    return pageVC ;
}

+ (instancetype)getMeForce {
    NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:UIPageViewControllerOptionInterPageSpacingKey] ;
    OctGuidingVC *pageVC = [[OctGuidingVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option] ;
    pageVC.kForce = YES ;
    pageVC.view.xt_theme_backgroundColor = k_md_bgColor ;
    return pageVC ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.fd_prefersNavigationBarHidden = YES ;

    SingleGuidVC *guid1 = [SingleGuidVC getMeWithType:1] ;
    SingleGuidVC *guid2 = [SingleGuidVC getMeWithType:2] ;
    SingleGuidVC *guid3 = [SingleGuidVC getMeWithType:3] ;
    guid3.delegate = self ;
    self.vcList = @[guid1,guid2,guid3] ;
    [self setViewControllers:@[guid1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil] ;
    self.delegate = self ;
    self.dataSource = self ;
    
    
    _pageCtrl = [[EllipsePageControl alloc] init] ;
    _pageCtrl.frame = CGRectMake(0, APP_HEIGHT - 30 - 50, APP_WIDTH, 30);
    _pageCtrl.numberOfPages = 3 ;
    _pageCtrl.delegate = self ;
    _pageCtrl.currentColor = UIColorHex(@"F55333") ;
    _pageCtrl.otherColor = UIColorHexA(@"181211", .5) ;
    _pageCtrl.controlSize = 8 ;
    _pageCtrl.controlSpacing = 15 ;
    [self.view addSubview:_pageCtrl] ;
    [_pageCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(APP_WIDTH, 30)) ;
        make.bottom.equalTo(self.view).offset(-10) ;
        make.centerX.equalTo(self.view) ;
    }] ;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.vcList indexOfObject:viewController];
    if (index == 0 || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self.vcList objectAtIndex:index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.vcList indexOfObject:viewController];
    if (index == self.vcList.count - 1 || (index == NSNotFound)) {
        return nil;
    }
    index++;
    return [self.vcList objectAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {

    UIViewController *nextVC = [pendingViewControllers firstObject];
    NSInteger index = [self.vcList indexOfObject:nextVC];
    ld_currentIndex = index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {

    NSLog(@"didFinishAnimating");
    NSLog(@"%d", completed);
    if (completed) {
        _pageCtrl.currentPage = ld_currentIndex ;
        NSLog(@">>>>>>>>> %ld", (long)ld_currentIndex);
    }
}


#pragma mark - EllipsePageControlDelegate

- (void)ellipsePageControlClick:(EllipsePageControl *)pageControl index:(NSInteger)clickIndex {
    UIViewController *vc = [self.vcList objectAtIndex:clickIndex];
    if (clickIndex > ld_currentIndex) {
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
    }
    else {
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        }];
    }
    ld_currentIndex = clickIndex;
}

#pragma mark - SingleGuidVCDelegate <NSObject>

- (void)startOnClick {
    if (self.kForce) {
        [self dismissViewControllerAnimated:YES completion:nil] ;
        return ;
    }
        
    AppDelegate *appDelegaete = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
    appDelegaete.window.rootViewController = [OcHomeVC getMe] ;
    [appDelegaete.window makeKeyAndVisible] ;
    [appDelegaete.window makeKeyAndVisible] ;
}

@end
