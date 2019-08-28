//
//  SettingNavBar.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingNavBar.h"
#import "MDThemeConfiguration.h"
#import <BlocksKit+UIKit.h>
#import "GlobalDisplaySt.h"

@interface SettingNavBar ()
@property (strong, nonatomic) UIButton *back ;
@end

@implementation SettingNavBar

+ (void)addInController:(UIViewController *)ctrller {
    [self addInController:ctrller hiddenNavigationBackBt:NO] ;
}

+ (void)addInController:(UIViewController *)ctrller hiddenNavigationBackBt:(BOOL)hide {
    SettingNavBar *navBar = [[SettingNavBar alloc] init] ;
    navBar.back.hidden = hide ;
    [ctrller.view addSubview:navBar] ;
    
    float topFlex = ([GlobalDisplaySt sharedInstance].isPopOverFromIpad) ? 0 : APP_STATUSBAR_HEIGHT ;
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ctrller.view.mas_top).offset(topFlex) ;
        make.left.right.equalTo(ctrller.view) ;
        make.height.equalTo(@49) ;
    }] ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.height = 49 ;
        self.xt_theme_backgroundColor = k_md_backColor ;
        
        UIButton *back = [UIButton new] ;
        back.size = CGSizeMake(20, 20) ;
        [back xt_enlargeButtonsTouchArea] ;
        [back setImage:[UIImage imageNamed:@"nav_back_item"] forState:0] ;
        back.xt_theme_imageColor = k_md_iconColor ;
        [self addSubview:back] ;
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20)) ;
            make.left.equalTo(self).offset(20) ;
            make.centerY.equalTo(self) ;
        }] ;
        WEAK_SELF
        [back bk_whenTapped:^{
            [weakSelf.xt_navigationController popViewControllerAnimated:YES] ;
        }] ;
        self.back = back ;
        
        UIButton *close = [UIButton new] ;
        close.size = CGSizeMake(20, 20) ;
        [close xt_enlargeButtonsTouchArea] ;
        [close setImage:[UIImage imageNamed:@"m_note_close"] forState:0] ;
        close.xt_theme_imageColor = k_md_iconColor ;
        [self addSubview:close] ;
        [close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20)) ;
            make.right.equalTo(self).offset(-20) ;
            make.centerY.equalTo(self) ;
        }] ;
        [close bk_whenTapped:^{
            [weakSelf.xt_viewController dismissViewControllerAnimated:YES completion:nil] ;
        }] ;
    }
    return self;
}


@end
