//
//  MDCodeBlockEditor.m
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDCodeBlockEditor.h"
#import "MDThemeConfiguration.h"


@implementation MDCodeBlockEditor

- (instancetype)initWithFrame:(CGRect)frame
                        model:(MdBlockModel *)model {
    
    self = [super initWithFrame:frame];
    if (self) {
//        self.xt_theme_backgroundColor = [] //XT_MAKE_theme_color(k_md_themeColor, .3) ;
//        self.xt_theme_textColor = k_md_themeColor ;
        self.scrollEnabled = NO ;
        self.backgroundColor = nil ;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:model.str attributes:[MDThemeConfiguration sharedInstance].editorThemeObj.codeBlockStyle] ;
        self.attributedText = attributedString ;
        
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
