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
#import <BlocksKit+UIKit.h>

@implementation KeyboardViewButton

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    [self xt_setImagePosition:(XTBtImagePositionTop) spacing:4] ;
    [self setTitleColor:UIColorHexA(@"6b737b",.5) forState:(UIControlStateNormal)] ;
    [self setTitleColor:UIColorHex(@"6b737b") forState:(UIControlStateSelected)] ;
    UIImage *grayImage = [UIImage imageWithColor:UIColorRGBA(107, 115, 123, .1) size:CGSizeMake(80, 60)] ;
    [self setBackgroundImage:grayImage forState:UIControlStateSelected] ;
    
    WEAK_SELF
    [self bk_addEventHandler:^(id sender) {
        
        
        weakSelf.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1) ;
        [UIView animateWithDuration:.2 animations:^{
            weakSelf.layer.transform = CATransform3DIdentity ;
        }] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
}

@end
