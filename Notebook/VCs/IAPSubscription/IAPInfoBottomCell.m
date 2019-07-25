//
//  IAPInfoBottomCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPInfoBottomCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"

@implementation IAPInfoBottomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.lbInfo.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.btReply.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btReply.xt_borderWidth = .5 ;
    self.btReply.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, .2) ;
    self.btReply.backgroundColor = nil ;
    self.btReply.xt_cornerRadius = 6 ;
    
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_drawerSelectedColor ;

    self.lbPrivacy.xt_theme_textColor =  self.lbService.xt_theme_textColor = k_md_themeColor ;
    
    self.btImage.xt_theme_imageColor = k_md_iconColor ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)xt_cellHeight {
    return 400. ;
}

@end