//
//  GuidingVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "GuidingVC.h"
#import "GuidingView.h"
#import <EllipsePageControl/EllipsePageControl.h>
#import "AppDelegate.h"
#import "HomeVC.h"
#import "MDNavVC.h"

@interface GuidingVC () <UIScrollViewDelegate, EllipsePageControlDelegate>
@property (nonatomic, strong) UIScrollView *scrollView ;
@property (nonatomic, strong) EllipsePageControl *pageCtrl ;
@property (nonatomic, strong) GuidingView *guidView ;
@end

@implementation GuidingVC

#define CurrentHeight   APP_HEIGHT - APP_STATUSBAR_HEIGHT
//[UIView currentScreenBoundsDependOnOrientation].size.height
#define CurrentWidth    APP_WIDTH
//[UIView currentScreenBoundsDependOnOrientation].size.width



+ (GuidingVC *)show {
    if (IS_IPAD) {
        return nil ;
    }

    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
    if ([currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending) return nil ;
    
    GuidingVC *vc = [[GuidingVC alloc] init] ;
    XT_USERDEFAULT_SET_VAL(currentVersion, kKey_markForGuidingDisplay) ;
    return vc ;
}


- (float)screenHeight {
//    if (CurrentHeight > CurrentWidth) {
//        return CurrentHeight ;
//    }
//    else {
//        return CurrentHeight ;
//    }
    return CurrentHeight ;
}

- (float)screenWid {
    return CurrentWidth ;
//    if (CurrentHeight > CurrentWidth) {
//        return CurrentWidth ;
//    }
//    else {
//        return CurrentWidth ; //CurrentHeight / 16 * 9 ;
//    }
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews] ;
//
//    self.guidView.frame = CGRectMake(0, 0, self.screenWid * 3, self.screenHeight) ;
//    self.scrollView.contentSize = CGSizeMake(self.screenWid * 3, self.screenHeight) ;
//    self.scrollView.frame = self.view.bounds ;
//}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.scrollView = ({
        UIScrollView *scroll = [[UIScrollView alloc] init] ;
        scroll.frame = self.view.bounds ;
        [self.view addSubview:scroll] ;
        scroll ;
    }) ;
    
    GuidingView *guidView = [GuidingView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    guidView.frame = CGRectMake(0, 0, self.screenWid * 3, self.screenHeight) ;
    [self.scrollView addSubview:guidView] ;
    self.guidView = guidView ;
    
    self.scrollView.contentSize = CGSizeMake(self.screenWid * 3, self.screenHeight) ;
    self.scrollView.showsHorizontalScrollIndicator = NO ;
    self.scrollView.showsVerticalScrollIndicator   = NO ;
    self.scrollView.pagingEnabled = YES ;
    self.scrollView.backgroundColor = [UIColor whiteColor] ;
    self.scrollView.delegate = self ;
    
    
    WEAK_SELF
    [guidView.lbStart xt_whenTapped:^{
//        [weakSelf dismissViewControllerAnimated:YES completion:^{
//        }] ;
        HomeVC *homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:weakSelf.class] controllerIdentifier:@"HomeVC"] ;
        MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:homeVC] ;
        AppDelegate *appDelegaete = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
        appDelegaete.window.rootViewController = navVC ;
        [appDelegaete.window makeKeyAndVisible] ;
    }] ;
    
    
    _pageCtrl = [[EllipsePageControl alloc] init] ;
    _pageCtrl.frame = CGRectMake(0, self.screenHeight - 30 - 50, self.screenWid, 30);
    _pageCtrl.numberOfPages = 3 ;
    _pageCtrl.delegate = self ;
    _pageCtrl.currentColor = [[MDThemeConfiguration sharedInstance] themeColor:k_md_themeColor] ;
    _pageCtrl.otherColor = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, .5)] ;
    _pageCtrl.controlSize = 8 ;
    _pageCtrl.controlSpacing = 15 ;
    [self.view addSubview:_pageCtrl] ;
}

#pragma mark - scrollview

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = scrollView.mj_offsetX / self.screenWid ;
    if (_pageCtrl.currentPage != index) {
        self.pageCtrl.currentPage = index ;
    }
}

#pragma mark - EllipsePageControlDelegate

- (void)ellipsePageControlClick:(EllipsePageControl *)pageControl index:(NSInteger)clickIndex {
    int index = self.scrollView.mj_offsetX / self.screenWid ;
    if (clickIndex == index) return ;
    
    [UIView animateWithDuration:.6 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        self.scrollView.mj_offsetX = clickIndex * self.screenWid ;
    } completion:^(BOOL finished) {
        
    }] ;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
