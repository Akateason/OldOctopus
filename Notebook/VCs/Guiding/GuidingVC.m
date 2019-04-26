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

@interface GuidingVC () <UIScrollViewDelegate, EllipsePageControlDelegate>
@property (nonatomic, strong) UIScrollView *scrollView ;
@property (nonatomic, strong) EllipsePageControl *pageCtrl ;

@end

@implementation GuidingVC

static NSString *const kKey_markForGuidingDisplay = @"kKey_markForGuidingDisplay" ;

+ (void)showFromCtrllerIfNeeded:(UIViewController *)ctrller {
    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
    if ([currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending) return ;
    
    GuidingVC *vc = [[GuidingVC alloc] init] ;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
    [ctrller presentViewController:vc animated:NO completion:^{
    }] ;
    XT_USERDEFAULT_SET_VAL(currentVersion, kKey_markForGuidingDisplay) ;
}


//
//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}
//



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews] ;
    
    self.scrollView.frame = [UIView currentScreenBoundsDependOnOrientation] ;
    self.scrollView.contentSize = CGSizeMake([UIView currentScreenBoundsDependOnOrientation].size.width * 3, [UIView currentScreenBoundsDependOnOrientation].size.height) ;

}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.scrollView = ({
        UIScrollView *scroll = [[UIScrollView alloc] init] ;
        scroll.frame = [UIView currentScreenBoundsDependOnOrientation] ;
        [self.view addSubview:scroll] ;
        scroll ;
    }) ;
    
    GuidingView *guidView = [GuidingView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    guidView.frame = CGRectMake(0, 0, [UIView currentScreenBoundsDependOnOrientation].size.width * 3, [UIView currentScreenBoundsDependOnOrientation].size.height) ;
    [self.scrollView addSubview:guidView] ;
    
    self.scrollView.contentSize = CGSizeMake([UIView currentScreenBoundsDependOnOrientation].size.width * 3, [UIView currentScreenBoundsDependOnOrientation].size.height) ;
    self.scrollView.showsHorizontalScrollIndicator = NO ;
    self.scrollView.showsVerticalScrollIndicator   = NO ;
    self.scrollView.pagingEnabled = YES ;
    self.scrollView.backgroundColor = [UIColor whiteColor] ;
    self.scrollView.delegate = self ;
    
    WEAK_SELF
    [guidView.lbStart bk_whenTapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{
        }] ;
    }] ;
    
    
    _pageCtrl = [[EllipsePageControl alloc] init] ;
    _pageCtrl.frame = CGRectMake(0, [UIView currentScreenBoundsDependOnOrientation].size.height - 30 - 50,[UIView currentScreenBoundsDependOnOrientation].size.width, 30);
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
    int index = scrollView.mj_offsetX / [UIView currentScreenBoundsDependOnOrientation].size.width ;
    if (_pageCtrl.currentPage != index) {
        self.pageCtrl.currentPage = index ;
    }
}

#pragma mark - EllipsePageControlDelegate

- (void)ellipsePageControlClick:(EllipsePageControl *)pageControl index:(NSInteger)clickIndex {
    int index = self.scrollView.mj_offsetX / [UIView currentScreenBoundsDependOnOrientation].size.width ;
    if (clickIndex == index) return ;
    
    [UIView animateWithDuration:.6 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        self.scrollView.mj_offsetX = clickIndex * [UIView currentScreenBoundsDependOnOrientation].size.width ;
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
