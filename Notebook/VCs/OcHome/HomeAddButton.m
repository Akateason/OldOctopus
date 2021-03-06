//
//  HomeAddButton.m
//  Notebook
//
//  Created by teason23 on 2019/8/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeAddButton.h"
//#import

@implementation HomeAddButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = nil ;
        self.frame = CGRectMake(0, 0, 50, 50) ;
        
        UIColor *themeColor = XT_GET_MD_THEME_COLOR_KEY(k_md_themeColor) ;
        UIImage *bg = [[UIImage imageNamed:@"home_add_bg_light"] xt_imageWithTintColor:themeColor] ;
        self.imgBg = [[UIImageView alloc] initWithImage:bg] ;
        [self addSubview:self.imgBg] ;
        [self.imgBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self) ;
        }] ;
        
        self.imgAdd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_jiahao"]] ;
        [self addSubview:self.imgAdd] ;
        [self.imgAdd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self) ;
        }] ;
        

        self.imgBg.xt_theme_imageColor = k_md_themeColor ;
    }
    return self;
}

@end
