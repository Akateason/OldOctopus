//
//  RowHeightCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "RowHeightCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "SettingSave.h"

@implementation RowHeightCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_backColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    self.slider.minimumValue = 1.2 ;
    self.slider.maximumValue = 2. ;
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged] ;
    self.slider.tintColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    self.slider.maximumTrackTintColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    self.slider.thumbTintColor = XT_GET_MD_THEME_COLOR_KEY(k_md_themeColor) ;
    
    self.lbSlideVal.top = 0 ;
    self.lbSlideVal.xt_theme_textColor = k_md_themeColor ;
    
    UIView *tableTopLine = [UIView new] ;
    tableTopLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    [self addSubview:tableTopLine] ;
    [tableTopLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self) ;
        make.top.equalTo(self.mas_top) ;
        make.height.equalTo(@.5) ;
    }] ;
    
    UIView *bottomLine = [UIView new] ;
    bottomLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    [self addSubview:bottomLine] ;
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self) ;
        make.bottom.equalTo(self.mas_bottom) ;
        make.height.equalTo(@.5) ;
    }] ;
}

- (void)sliderChanged:(UISlider *)slider {
    self.lbSlideVal.text = XT_STR_FORMAT(@"%.1f",slider.value) ;
    
    SettingSave *sSave = [SettingSave fetch] ;
    sSave.editor_lightHeightRate = slider.value;
    [sSave save] ;
}

+ (CGFloat)xt_cellHeight {
    return 80. ;
}

@end
