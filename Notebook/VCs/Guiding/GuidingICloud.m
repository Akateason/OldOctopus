//
//  GuidingICloud.m
//  Notebook
//
//  Created by teason23 on 2019/5/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "GuidingICloud.h"

#import "MDThemeConfiguration.h"
#import "Note.h"
#import "MarkdownVC.h"
#import "AppDelegate.h"



@implementation GuidingICloud
XT_SINGLETON_M(GuidingICloud)

+ (instancetype)showFromCtrller:(UIViewController *)fromCtrller {
    GuidingICloud *guid = [GuidingICloud xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    [[UIView xt_topWindow] addSubview:guid] ;
    [guid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIView xt_topWindow]) ;
    }] ;
    guid.fromCtrller = fromCtrller ;
    return guid ;
}

+ (instancetype)show {
    return [self showFromCtrller:nil] ;
}





- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.hud.xt_theme_backgroundColor = k_md_bgColor ;
    self.hud.xt_cornerRadius = 20 ;
    self.lb1.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lb2.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.lb3.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbHowToOpen.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;

    self.btOpen.textColor = [UIColor whiteColor] ;
    self.btOpen.userInteractionEnabled = YES ;
    self.btOpen.xt_theme_backgroundColor = k_md_themeColor ;
    self.btOpen.xt_completeRound = YES ;
    self.lbHowToOpen.userInteractionEnabled = YES ;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.2] ;
    
    
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
    [self.btOpen xt_whenTapped:^{
        //Specifically, your app uses the following non-public URL scheme:
        //- app-prefs:root=castle
        //To resolve this issue, please revise your app to provide the associated functionality using public APIs or remove the functionality using the "prefs:root" or "App-Prefs:root" URL scheme.
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root"] ;
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil] ;
    }] ;
    
    [self.lbHowToOpen xt_whenTapped:^{
        Note *aNote = [Note xt_findFirstWhere:@"icRecordName == 'iOS-note-guide'"] ;
        if (aNote.content) {
            if (!weakSelf.fromCtrller) {
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                UINavigationController *navVC = (UINavigationController *)(appDelegate.window.rootViewController) ;
                weakSelf.fromCtrller = navVC.topViewController ;
            }
            
            [MarkdownVC newWithNote:aNote bookID:aNote.noteBookId fromCtrller:weakSelf.fromCtrller] ;
            [weakSelf removeFromSuperview] ;
        }
    }] ;
    
    [self.btClose xt_whenTapped:^{
        [weakSelf removeFromSuperview] ;
    }] ;
}

@end
