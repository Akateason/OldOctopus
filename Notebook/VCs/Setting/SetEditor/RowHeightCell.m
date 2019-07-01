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
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    self.slider.minimumValue = 1.2 ;
    self.slider.maximumValue = 2. ;
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged] ;
    self.slider.tintColor = XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    self.slider.maximumTrackTintColor = XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    self.slider.thumbTintColor = XT_MD_THEME_COLOR_KEY(k_md_themeColor) ;
    
    self.lbSlideVal.top = 0 ;
    self.lbSlideVal.xt_theme_textColor = k_md_themeColor ;
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
