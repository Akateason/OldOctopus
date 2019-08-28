//
//  ThemeCollectCell.m
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ThemeCollectCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "IapUtil.h"

@implementation ThemeCollectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    self.xt_cornerRadius = 10. ;
    
}

//
//+ (CGSize)xt_cellSizeForModel:(id)model {
//    float wid = ( [model floatValue] - 20. * 2. - 10. ) / 2. ;
//    float height = wid / 325. * 200. ;
//    return CGSizeMake(wid, height) ;
//}

- (void)setThemeStr:(NSString *)str {
    self.imageView.image = [UIImage imageNamed:STR_FORMAT(@"theme_%@",str)] ;
    
//    BOOL isLightTheme = [str isEqualToString:@"light"] ;
//    BOOL isVip = NO ;
    // [IapUtil isIapVipFromLocalAndRequestIfLocalNotExist] ;
    
    
}

- (void)setOnSelect:(BOOL)on {
    self.imgLock.image = on ? [UIImage imageNamed:@"theme_select"] : [UIImage imageNamed:@"theme_lock"] ;
    
    BOOL isVip = [IapUtil isIapVipFromLocalAndRequestIfLocalNotExist] ;
    
    if (isVip) {
        self.imgLock.hidden = !on ;
    }
    else {
        self.imgLock.hidden = NO ;
    }
}

@end
