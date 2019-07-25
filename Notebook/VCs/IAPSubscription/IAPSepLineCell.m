//
//  IAPSepLineCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPSepLineCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"

@implementation IAPSepLineCell

+ (CGFloat)xt_cellHeight {
    return 30. ;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = 0 ;
    self.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_midDrawerPadColor) ;
    self.bottomLine.backgroundColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, .2) ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
