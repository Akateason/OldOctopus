//
//  OctShareCopyLinkView.m
//  Notebook
//
//  Created by teason23 on 2019/7/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctShareCopyLinkView.h"
#import <XTlib/XTlib.h>
#import <BlocksKit+UIKit.h>
#import "MDThemeConfiguration.h"


@implementation OctShareCopyLinkView

+ (void)showOnView:(UIView *)onView
              link:(NSString *)link
          complete:(OctCompletion)completeBlk {
    
    OctShareCopyLinkView *share = [OctShareCopyLinkView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    [onView addSubview:share] ;
    share.tf.text = link ;
    [share mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(onView.window) ;
    }] ;
    share.completion = completeBlk ;
}


- (IBAction)cancelAction:(id)sender {
    self.completion(NO) ;
    [self removeFromSuperview] ;
}

- (IBAction)confirmAction:(id)sender {
    self.completion(YES) ;
    [self removeFromSuperview] ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.3] ;
    self.hud.xt_cornerRadius = 6 ;
    self.hud.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.tf.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.tf.userInteractionEnabled = NO ;
    self.tf.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    
    self.btConfirm.xt_cornerRadius = self.btCancel.xt_cornerRadius = 8 ;
    self.btConfirm.xt_borderColor = self.btCancel.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .2) ;
    self.btConfirm.xt_borderWidth = self.btCancel.xt_borderWidth = 1 ;
    
    self.btConfirm.xt_theme_textColor = k_md_textColor ;
    self.btCancel.xt_theme_textColor = k_md_textColor ;
    
    
}





@end
