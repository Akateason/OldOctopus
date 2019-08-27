//
//  GuidingICloud.m
//  Notebook
//
//  Created by teason23 on 2019/5/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "GuidingICloud.h"
#import <BlocksKit+UIKit.h>
#import "MDThemeConfiguration.h"
#import "Note.h"
#import "MarkdownVC.h"
#import "AppDelegate.h"
#import "GlobalDisplaySt.h"
#import "HomeVC.h"


@implementation GuidingICloud
XT_SINGLETON_M(GuidingICloud)


+ (instancetype)show {
    GuidingICloud *guid = [GuidingICloud xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    [[UIView xt_topWindow] addSubview:guid] ;
    [guid mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPAD) {
            make.size.mas_equalTo(CGSizeMake(400, 800)) ;
        }
        else {
            make.size.mas_equalTo(APPFRAME.size) ;
        }
        make.center.equalTo([UIView xt_topWindow]) ;
    }] ;
    return guid ;
}





- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.hud.xt_theme_backgroundColor = k_md_drawerColor ;
    self.img.xt_theme_imageColor = k_md_iconColor ;
    self.hud.xt_cornerRadius = 20 ;
    self.lb1.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lb2.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.lbHowToOpen.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;

    self.btOpen.textColor = [UIColor whiteColor] ;
    self.btOpen.userInteractionEnabled = YES ;
    self.lbHowToOpen.userInteractionEnabled = YES ;
    
    UIView *bg = [UIView new] ;
    bg.xt_cornerRadius = 17.5 ;
    bg.xt_gradientPt0 = CGPointMake(0, .5) ;
    bg.xt_gradientPt1 = CGPointMake(1, .5) ;
    bg.xt_gradientColor0 = UIColorHex(@"fe4241") ;
    bg.xt_gradientColor1 = UIColorHex(@"fe8c68") ;
    bg.xt_maskToBounds = YES ;
    [self.hud insertSubview:bg belowSubview:self.btOpen] ;
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.btOpen) ;
    }] ;
    
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
            
            if (user != nil && self.window != nil) {
                [self removeFromSuperview] ;
                [SVProgressHUD showSuccessWithStatus:@"已登录成功"] ;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNote_User_Login_Success object:nil] ;
            }
        }] ;
    }] ;
    
    
    WEAK_SELF
    [self.btOpen bk_whenTapped:^{
        //Specifically, your app uses the following non-public URL scheme:
        //- app-prefs:root=castle
        //To resolve this issue, please revise your app to provide the associated functionality using public APIs or remove the functionality using the "prefs:root" or "App-Prefs:root" URL scheme.
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root"] ;
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil] ;
    }] ;
    
    [self.lbHowToOpen bk_whenTapped:^{
        Note *aNote = [Note xt_findFirstWhere:@"icRecordName == 'iOS-note-guide'"] ;
        if (aNote.content) {
            if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                UINavigationController *navVC = (UINavigationController *)(appDelegate.window.rootViewController) ;
                [MarkdownVC newWithNote:aNote bookID:aNote.noteBookId fromCtrller:navVC.topViewController] ;
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNote_ClickNote_In_Pad object:aNote] ;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNote_pad_Editor_OnClick object:nil] ;
            }
            
            
            
            [weakSelf removeFromSuperview] ;
        }
    }] ;
    
    [self.btClose bk_whenTapped:^{
        [weakSelf removeFromSuperview] ;
    }] ;
    
    if (IS_IPAD) {
        self.backgroundColor = nil ;
    }
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
