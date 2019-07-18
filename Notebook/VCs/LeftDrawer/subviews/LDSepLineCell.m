//
//  LDSepLineCell.m
//  Notebook
//
//  Created by teason23 on 2019/4/17.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LDSepLineCell.h"
#import "MDThemeConfiguration.h"

@implementation LDSepLineCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.sep.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    self.xt_theme_backgroundColor = k_md_drawerColor ;
    self.selectionStyle = 0 ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
