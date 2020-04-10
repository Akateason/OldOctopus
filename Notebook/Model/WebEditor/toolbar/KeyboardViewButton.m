//
//  KeyboardViewButton.m
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "KeyboardViewButton.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"


@implementation KeyboardViewButton

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    [self xt_setImagePosition:(XTBtImagePositionTop) spacing:4] ;
        
    
    [self setTitleColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .4) forState:(UIControlStateNormal)] ;
    [self setTitleColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) forState:(UIControlStateSelected)] ;
    
    [[RACObserve(self, selected) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        self.backgroundColor = [x boolValue] ? UIColorRGBA(107, 115, 123, .1) : XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
    }] ;
    
    WEAK_SELF
    [self xt_addEventHandler:^(id sender) {
        weakSelf.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1) ;
        [UIView animateWithDuration:.2 animations:^{
            weakSelf.layer.transform = CATransform3DIdentity ;
        }] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
}

@end
