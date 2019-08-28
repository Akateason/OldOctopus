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
        
        _swt.thumbOnTintColor = XT_GET_MD_THEME_COLOR_KEY(k_md_themeColor) ;
        _swt.thumbOffTintColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
        _swt.trackOnTintColor = XT_GET_MD_THEME_COLOR_KEY(k_md_themeColor) ;
        _swt.trackOffTintColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .4) ;
        _swt.rippleFillColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
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
//    self.xt_theme_backgroundColor = k_md_backColor ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbDesc.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.imgRightCorner.userInteractionEnabled = NO ;
    
    self.topLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    self.bottomLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
}

+ (CGFloat)xt_cellHeight {
    return 50. ;
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

- (void)setSepLineMode:(SettingCellSeperateLine_Mode)sepLineMode {
    switch (sepLineMode) {
        case SettingCellSeperateLine_Mode_ALL_FULL:{
            self.topLine.hidden = self.bottomLine.hidden = NO ;
            self.left_topLine.constant = 0 ;
        }
            break;
        case SettingCellSeperateLine_Mode_Top: {
            self.topLine.hidden = NO ;
            self.bottomLine.hidden = YES ;
            self.left_topLine.constant = 0 ;
        }
            break;
        case SettingCellSeperateLine_Mode_Bottom: {
            self.topLine.hidden = self.bottomLine.hidden = NO ;
            self.left_topLine.constant = 25 ;
        }
            break ;
        case SettingCellSeperateLine_Mode_Middel: {
            self.topLine.hidden = NO ;
            self.bottomLine.hidden = YES ;
            self.left_topLine.constant = 25 ;
        }
            break ;
        default:
            break;
    }
}

#pragma mark - JTMaterialSwitchDelegate <NSObject>

- (void)switchStateChanged:(JTMaterialSwitchState)currentState {
    [self.delegate switchStateChanged:currentState dic:self.xt_model] ;
}

@end
