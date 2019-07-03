//
//  TrashEmptyView.m
//  Notebook
//
//  Created by teason23 on 2019/4/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "TrashEmptyView.h"
#import "MDThemeConfiguration.h"

@implementation TrashEmptyView

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.xt_theme_backgroundColor = IS_IPAD ? k_md_midDrawerPadColor : k_md_bgColor ;
}

@end
