//
//  HomeSearchCell.m
//  Notebook
//
//  Created by teason23 on 2019/4/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeSearchCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"

@implementation HomeSearchCell

+ (CGFloat)xt_cellHeight {
    return 53. ;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.scBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, 0.03) ;
    self.lbPh.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.scBar.xt_cornerRadius = 6 ;
    
    self.selectionStyle = 0 ;
    
//    self.backgroundColor = [UIColor xt_red] ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
