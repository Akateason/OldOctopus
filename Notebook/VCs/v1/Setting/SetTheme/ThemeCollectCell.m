//
//  ThemeCollectCell.m
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ThemeCollectCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "IapUtil.h"

@implementation ThemeCollectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imageView.xt_borderWidth = .5 ;
    self.imageView.xt_cornerRadius = 6. ;
    self.lbColorName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbTip.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    
    
}

- (void)setThemeStr:(NSString *)str {
    self.imageView.image = [UIImage imageNamed:STR_FORMAT(@"theme_%@",str)] ;
    self.imageView.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    self.lbTip.hidden = [str isEqualToString:@"light"] ;
    self.lbColorName.text = [[MDThemeConfiguration sharedInstance] formatLanguageForKey:str] ;
}

- (void)setOnSelect:(BOOL)on {
    self.imgLock.image = on ? [UIImage imageNamed:@"theme_select"] : [UIImage imageNamed:@"theme_lock"] ;
    self.imgLock.xt_completeRound = on ;
    self.imgLock.backgroundColor = on ? XT_GET_MD_THEME_COLOR_KEY(k_md_themeColor) : nil ;
    
    BOOL isVip = [IapUtil isIapVipFromLocalAndRequestIfLocalNotExist] ;
    
    if (isVip) {
        self.imgLock.hidden = !on ;
    }
    else {
        self.imgLock.hidden = NO ;
    }
}

@end
