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

@implementation ThemeCollectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.xt_borderColor = UIColorHex(@"f5502f") ;
    self.xt_borderWidth = 1. ;
    self.xt_cornerRadius = 10. ;
    
}


+ (CGSize)xt_cellSizeForModel:(id)model {
    float wid = ( [model floatValue] - 20. * 2. - 10. ) / 2. ;
    float height = wid / 325. * 200. ;
    return CGSizeMake(wid, height) ;
}

- (void)setThemeStr:(NSString *)str {
    self.imageView.image = [UIImage imageNamed:STR_FORMAT(@"theme_%@",str)] ;
}

- (void)setOnSelect:(BOOL)on {
    self.xt_borderWidth = on ? 1. : 0 ;
}

@end
