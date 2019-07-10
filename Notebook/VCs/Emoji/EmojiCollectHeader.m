//
//  EmojiCollectHeader.m
//  Notebook
//
//  Created by teason23 on 2019/7/9.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "EmojiCollectHeader.h"
#import "MDThemeConfiguration.h"

@implementation EmojiCollectHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
}

@end
