//
//  UIView+OctupusExtension.m
//  Notebook
//
//  Created by teason23 on 2019/4/18.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UIView+OctupusExtension.h"
#import "MDThemeConfiguration.h"

@implementation UIView (OctupusExtension)

- (void)oct_addBlurBg {
    [self oct_addBlurBgWithAlpha:.97] ;
}

- (void)oct_addBlurBgWithAlpha:(float)alpha {
    BOOL isDarkMode = [[MDThemeConfiguration sharedInstance].currentThemeKey containsString:@"Dark"] ;
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:isDarkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight] ;
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct] ;
    visualEffectView.alpha = alpha ;
    [self insertSubview:visualEffectView atIndex:0] ;
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self) ;
    }] ;
}


- (void)oct_addBlurBg_light {    
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] ;
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct] ;
    visualEffectView.alpha = 0.97 ;
    [self insertSubview:visualEffectView atIndex:0] ;
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self) ;
    }] ;
}



@end
