//
//  LDHeadView.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LDHeadView.h"
#import "XTCloudHandler.h"
#import "MDThemeConfiguration.h"
#import <BlocksKit+UIKit.h>

@implementation LDHeadView

- (void)setupUser {
    self.xt_theme_backgroundColor = k_md_bgColor ;

    
    XTIcloudUser *user = [XTIcloudUser userInCacheSyncGet] ;
    self.lbHead.text = [user.givenName substringToIndex:1] ;
    self.lbHead.xt_theme_backgroundColor = k_md_themeColor ;
    self.lbHead.textColor = [UIColor whiteColor] ;
    
    self.lbName.text = user.name ;
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    
    self.lbMyBook.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    
    self.imgAddBook.userInteractionEnabled = YES ;
    
    [self.imgAddBook bk_whenTapped:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_AddBook object:nil];
    }] ;
}

- (void)setDistance:(float)distance {
    self.rightFlex_addImage.constant = APP_WIDTH - distance + 22 ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
