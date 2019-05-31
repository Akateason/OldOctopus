//
//  HrView.m
//  Notebook
//
//  Created by teason23 on 2019/5/14.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HrView.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"


@implementation HrView

static float const kCornerWid = 3 ;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, APP_WIDTH - 30 * 2, 16) ;
        
        UIView *pt1 = [UIView new] ;
        pt1.xt_cornerRadius = kCornerWid / 2. ;
        pt1.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .7) ;
        [self addSubview:pt1] ;
        [pt1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self) ;
            make.size.mas_equalTo(CGSizeMake(kCornerWid, kCornerWid)) ;
        }] ;
        
        UIView *pt2 = [UIView new] ;
        pt2.xt_cornerRadius = kCornerWid / 2. ;
        pt2.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .7) ;
        [self addSubview:pt2] ;
        [pt2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY) ;
            make.right.equalTo(self.mas_centerX).offset(-15) ;
            make.size.mas_equalTo(CGSizeMake(kCornerWid, kCornerWid)) ;
        }] ;
        
        UIView *pt3 = [UIView new] ;
        pt3.xt_cornerRadius = kCornerWid / 2. ;
        pt3.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .7) ;
        [self addSubview:pt3] ;
        [pt3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY) ;
            make.left.equalTo(self.mas_centerX).offset(15) ;
            make.size.mas_equalTo(CGSizeMake(kCornerWid, kCornerWid)) ;
        }] ;
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
