//
//  HomeEmptyPHView.m
//  Notebook
//
//  Created by teason23 on 2019/4/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeEmptyPHView.h"
#import "MDThemeConfiguration.h"

@implementation HomeEmptyPHView


- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.btNewNote.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.imgCenter.xt_theme_imageColor = k_md_iconColor ;
}




@end
