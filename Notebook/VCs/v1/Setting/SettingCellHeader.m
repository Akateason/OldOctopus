//
//  SettingCellHeader.m
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingCellHeader.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"



@implementation SettingCellHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.lbTitle = ({
            UILabel *lb = [UILabel new] ;
            lb.font = [UIFont systemFontOfSize:12] ;
            lb.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
            [self addSubview:lb] ;
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@20) ;
                make.bottom.equalTo(@-10) ;
            }] ;
            lb ;
        }) ;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds] ;
        backgroundView.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_backColor) ;
        self.backgroundView = backgroundView ;
    }
    return self ;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
