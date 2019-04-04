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
    XTIcloudUser *user = [XTIcloudUser userInCacheSyncGet] ;
    self.lbHead.text = [user.givenName substringToIndex:1] ;
    self.lbHead.backgroundColor = [MDThemeConfiguration sharedInstance].themeColor ;
    self.lbHead.textColor = [UIColor whiteColor] ;
    
    self.lbName.text = user.name ;
    self.lbName.textColor = [MDThemeConfiguration sharedInstance].textColor ;
    self.lbName.alpha = .6 ;
    
    self.lbMyBook.textColor = [MDThemeConfiguration sharedInstance].textColor ;
    self.lbMyBook.alpha = .3 ;
    
    self.imgAddBook.userInteractionEnabled = YES ;
    WEAK_SELF
    [self.imgAddBook bk_whenTapped:^{
        [weakSelf.delegate addBook] ;
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
