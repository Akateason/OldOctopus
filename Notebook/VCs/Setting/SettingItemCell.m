//
//  SettingItemCell.m
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingItemCell.h"
#import "MDThemeConfiguration.h"
#import "SettingSave.h"
#import <BlocksKit+UIKit.h>

@implementation SettingItemCell

- (JTMaterialSwitch *)swt {
    if (!_swt) {
        _swt = [[JTMaterialSwitch alloc] initWithSize:(JTMaterialSwitchSizeSmall) style:(JTMaterialSwitchStyleDefault) state:(JTMaterialSwitchStateOff)] ;
//        _swt.right = APP_WIDTH - 20. ; // self.width - 20 ;
//        _swt.centerY = self.centerY ;
        
        _swt.thumbOnTintColor = XT_MD_THEME_COLOR_KEY(k_md_themeColor) ;
        _swt.thumbOffTintColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
        _swt.trackOnTintColor = XT_MD_THEME_COLOR_KEY(k_md_themeColor) ;
        _swt.trackOffTintColor = XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .4) ;
        _swt.rippleFillColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
        _swt.delegate = (id<JTMaterialSwitchDelegate>)self ;
        [self addSubview:_swt] ;
        [_swt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20) ;
            make.centerY.equalTo(self) ;
            make.size.mas_equalTo(CGSizeMake(30, 25)) ;
        }] ;
        
        _swt.hidden = YES ;
    }
    return _swt ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
 
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbDesc.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.imgRightCorner.userInteractionEnabled = NO ;
}



+ (CGFloat)xt_cellHeight {
    return 45 ;
}

- (void)xt_configure:(NSDictionary *)model {
    [super xt_configure:model] ;
    
    self.lbTitle.text = model[@"t"] ;
    self.lbDesc.text = model[@"r"] ;
    
    BOOL showSwt = [model[@"s"] boolValue] ;
    self.swt.hidden = !showSwt ;
    
    self.imgRightCorner.hidden = showSwt ;
    self.lbDesc.hidden = showSwt ;
}

#pragma mark - JTMaterialSwitchDelegate <NSObject>

- (void)switchStateChanged:(JTMaterialSwitchState)currentState {
    [self.delegate switchStateChanged:currentState dic:self.xt_model] ;
}

@end
