//
//  TableCreatorView.m
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "TableCreatorView.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"

@implementation TableCreatorView

+ (void)showOnView:(UIView *)onView
            window:(UIWindow *)window
    keyboardHeight:(CGFloat)keyboardHeight
          callback:(CallbackBlk)blk {
    
    TableCreatorView *creator = [TableCreatorView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    creator.xt_cornerRadius = 8 ;
    
    UIView *hud = [UIView new] ;
    hud.backgroundColor = [UIColor colorWithWhite:0 alpha:.8] ;
    [window addSubview:hud] ;
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window) ;
    }] ;
    
    [hud addSubview:creator] ;
    [creator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(window.mas_centerX) ;
        make.width.equalTo(@300) ;
        make.height.equalTo(@200) ;
        make.bottom.equalTo(window.mas_bottom).offset(- keyboardHeight) ;
    }] ;
    
    [creator.tfLineCount becomeFirstResponder] ;
    
    @weakify(creator)
    creator.blk = ^(BOOL isConfirm, NSString *line, NSString *column) {
        @strongify(creator)
        [creator removeFromSuperview] ;
        [hud removeFromSuperview] ;
        blk(isConfirm,line,column) ;
    } ;
}

- (IBAction)okAction:(id)sender {
    int line = [self.tfLineCount.text intValue] ;
    int column = [self.tfColumnCount.text intValue] ;
    if (line > 30 || column > 20) {
        [SVProgressHUD showErrorWithStatus:@"列表行或列超过限制"] ;
        return ;
    }
    
    self.blk(YES, self.tfLineCount.text, self.tfColumnCount.text) ;
}

- (IBAction)cancelAction:(id)sender {
    self.blk(NO, nil, nil) ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    _tfLineCount.placeholder = @"2" ;
    _tfColumnCount.placeholder = @"3" ;
    
    _tfLineCount.keyboardType = UIKeyboardTypeNumberPad ;
    _tfColumnCount.keyboardType = UIKeyboardTypeNumberPad ;
    
    self.xt_theme_backgroundColor = k_md_backColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btOk.xt_theme_textColor = k_md_textColor ;
    self.btCancel.xt_theme_textColor = k_md_textColor ;
    
    self.lbLine.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    self.lbColumn.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    
    self.btOk.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
    self.btCancel.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) ;
    
    self.tfLineCount.xt_theme_textColor = k_md_textColor ;
    self.tfColumnCount.xt_theme_textColor = k_md_textColor ;
    self.tfLineCount.xt_theme_backgroundColor = k_md_drawerColor ;
    self.tfColumnCount.xt_theme_backgroundColor = k_md_drawerColor ;
    
    UIColor *color = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .5) ;    
    
    self.tfLineCount.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"2" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:color}];
    
    self.tfColumnCount.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"3" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:color}];

}

@end
