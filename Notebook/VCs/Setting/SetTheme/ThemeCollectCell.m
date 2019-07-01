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
    
    _imageView.image = [UIImage imageNamed:@"tb_list"] ;
    
    self.xt_borderColor = XT_MD_THEME_COLOR_KEY(k_md_themeColor) ;
    self.xt_borderWidth = 1. ;
    self.xt_cornerRadius = 10. ;
    
}


+ (CGSize)xt_cellSize {
    float wid = ( APP_WIDTH - 20. * 2. - 10. ) / 2. ;
    float height = wid / 325. * 200. ;
    return CGSizeMake(wid, height) ;
}

- (void)setThemeStr:(NSString *)str {
    
}


@end
