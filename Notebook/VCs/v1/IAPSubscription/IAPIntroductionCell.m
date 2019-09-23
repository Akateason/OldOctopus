//
//  IAPIntroductionCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPIntroductionCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"


@implementation IAPIntroductionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;

    
    self.lb1.xt_theme_textColor = self.lb2.xt_theme_textColor = self.lb3.xt_theme_textColor = self.lb4.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    self.bottomLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)xt_cellHeight {
    return 314. ;
}

- (void)userHasSubscripte:(BOOL)subscripted {
    
    self.lbTitle.text = subscripted ? @"你已获得以下等更多功能" : @"订阅可获得以下等更多功能：" ;
}

@end
