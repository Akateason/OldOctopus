//
//  UnsplashCell.m
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UnsplashCell.h"

@implementation UnsplashCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
}

@end
