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

    self.hud.xt_cornerRadius = 20 ;
    self.lb1.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lb2.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.lbHowToOpen.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;

    self.btOpen.textColor = [UIColor whiteColor] ;
    self.btOpen.userInteractionEnabled = YES ;
    self.lbHowToOpen.userInteractionEnabled = YES ;
    
    UIView *bg = [UIView new] ;
    bg.xt_cornerRadius = 20 ;
    bg.xt_gradientPt0 = CGPointMake(0, .5) ;
    bg.xt_gradientPt1 = CGPointMake(1, .5) ;
    bg.xt_gradientColor0 = UIColorHex(@"fe4241") ;
    bg.xt_gradientColor1 = UIColorHex(@"fe8c68") ;
    bg.xt_maskToBounds = YES ;
    [self.hud insertSubview:bg belowSubview:self.btOpen] ;
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.btOpen) ;
    }] ;
    
    WEAK_SELF
    [self.btOpen bk_whenTapped:^{
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=CASTLE"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }] ;
    
    [self.lbHowToOpen bk_whenTapped:^{
        Note *aNote = [Note xt_findFirstWhere:@"icRecordName == 'iOS-note-guide'"] ;
        if (aNote.content) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate ;
            UINavigationController *navVC = (UINavigationController *)(appDelegate.window.rootViewController) ;
            [MarkdownVC newWithNote:aNote bookID:aNote.noteBookId fromCtrller:navVC.topViewController] ;
            
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