//
//  GuidingView.m
//  Notebook
//
//  Created by teason23 on 2019/4/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "GuidingView.h"
#import "MDThemeConfiguration.h"

@implementation GuidingView


- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    
    self.v1.size = APPFRAME.size ;
    self.v2.size = APPFRAME.size ;
    self.v3.size = APPFRAME.size ;
    
    self.lb1.textColor = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, .5)] ;
    self.lb2.textColor = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, .5)] ;
    self.lb3.textColor = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, .5)] ;
    
    self.tt1.textColor = [[MDThemeConfiguration sharedInstance] themeColor:k_md_themeColor] ;
    self.tt2.textColor = [[MDThemeConfiguration sharedInstance] themeColor:k_md_themeColor] ;
    self.tt3.textColor = [[MDThemeConfiguration sharedInstance] themeColor:k_md_themeColor] ;

    self.v1.backgroundColor = [UIColor whiteColor] ;
    self.v2.backgroundColor = [UIColor whiteColor] ;
    self.v3.backgroundColor = [UIColor whiteColor] ;
    
    
    UIView *graidentView = [UIView new] ;
    graidentView.frame = self.lbStart.frame ;
    graidentView.xt_gradientPt0 = CGPointMake(0, .5) ;
    graidentView.xt_gradientPt1 = CGPointMake(1, .5) ;
    graidentView.xt_gradientColor0 = UIColorHex(@"fe4241") ;
    graidentView.xt_gradientColor1 = UIColorHex(@"fe8c68") ;
    graidentView.xt_completeRound = YES ;
    [self.v3 insertSubview:graidentView belowSubview:self.lbStart] ;
    [graidentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.lbStart) ;
    }] ;
    self.lbStart.textColor = [UIColor whiteColor] ;
    self.lbStart.userInteractionEnabled = YES ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
