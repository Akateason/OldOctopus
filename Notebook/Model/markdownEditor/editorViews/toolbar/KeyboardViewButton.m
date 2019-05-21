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
//    self.xt_theme_backgroundColor =  ;
    [self setTitleColor:UIColorHexA(@"6b737b",.5) forState:(UIControlStateNormal)] ;
    [self setTitleColor:UIColorHex(@"6b737b") forState:(UIControlStateSelected)] ;
    
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
