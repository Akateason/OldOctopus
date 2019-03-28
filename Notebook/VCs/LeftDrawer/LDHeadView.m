//
//  LDHeadView.m
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LDHeadView.h"
#import "XTCloudHandler.h"

@implementation LDHeadView

- (void)setupUser {
    XTIcloudUser *user = [XTIcloudUser userInCacheSyncGet] ;
    self.lbHead.text = [user.givenName substringToIndex:1] ;
    self.lbHead.backgroundColor = [UIColor redColor] ;
    self.lbHead.textColor = [UIColor whiteColor] ;
    
    self.lbName.text = user.name ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
