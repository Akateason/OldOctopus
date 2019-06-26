//
//  SettingCell.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingCell.h"
#import "MDThemeConfiguration.h"

@implementation SettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.upContainer.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.rightTip.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.icon.xt_theme_imageColor = k_md_iconColor ;
}

+ (CGFloat)xt_cellHeight {
    return 55 ;
}

- (void)xt_configure:(NSDictionary *)model {
    [super xt_configure:model] ;
    
    self.icon.image = [UIImage imageNamed:model[@"p"]] ;
    self.lbTitle.text = model[@"t"] ;
    self.rightTip.text = model[@"r"] ;
}

@end
