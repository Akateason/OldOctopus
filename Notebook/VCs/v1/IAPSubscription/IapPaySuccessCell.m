//
//  IapPaySuccessCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IapPaySuccessCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"

@implementation IapPaySuccessCell

- (IBAction)btManageIapAction:(id)sender {
//    NSURL *url = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"] ;
//    [[UIApplication sharedApplication] openURL:url];
    
    // 暂时跳设置
    NSURL *url = [NSURL URLWithString:@"App-Prefs:root"] ;
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil] ;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.lbTip.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    
    self.btManage.backgroundColor = nil ;
    self.btManage.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btManage.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, .2) ;
    self.btManage.xt_borderWidth = .5 ;
    self.btManage.xt_cornerRadius = 6 ;
    
    [IapUtil fetchIapSubscriptionDate:^(long long tick) {
        NSLog(@"订阅有效期至 %@",[NSDate xt_getStrWithTick:tick / 1000. format:kTIME_STR_FORMAT_YYYYMMddHHmmss]) ;
        
        NSString *dateString = [NSDate xt_getStrWithTick:tick / 1000. format:kTIME_STR_FORMAT_yyyyMMdd_CHINESE_SPACE] ;
        self.lbTip.text = XT_STR_FORMAT(@"订阅有效期至 %@\n我们将会在以上的订阅时间到期时自动续期",dateString) ;
        
        if (k_Is_Internal_Testing) self.lbTip.text = @"小章鱼内测版, 可体验全部功能, 期待你的反馈" ;
    }] ;
    
}

+ (CGFloat)xt_cellHeight {
    return 190. ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
