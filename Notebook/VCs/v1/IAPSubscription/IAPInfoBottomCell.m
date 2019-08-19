//
//  IAPInfoBottomCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPInfoBottomCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import <BlocksKit+UIKit.h>

@implementation IAPInfoBottomCell

- (void)awakeFromNib {
    [super awakeFromNib] ;
    // Initialization code
    
    self.lbInfo.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.btReply.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btReply.xt_borderWidth = .5 ;
    self.btReply.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, .2) ;
    self.btReply.backgroundColor = nil ;
    self.btReply.xt_cornerRadius = 6 ;
    
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_drawerSelectedColor ;

    self.lbPrivacy.xt_theme_textColor =  self.lbService.xt_theme_textColor = k_md_themeColor ;
    
    self.btImage.xt_theme_imageColor = k_md_iconColor ;
    
    self.lbPrivacy.userInteractionEnabled = self.lbService.userInteractionEnabled = YES ;
    WEAK_SELF
    [self.lbPrivacy bk_whenTapped:^{
        [weakSelf.lbPrivacy oct_buttonClickAnimationComplete:^{
            NSString *urlStr = @"https://shimo.im/octopus#/privacy" ;
            NSURL *url = [NSURL URLWithString:urlStr] ;
            [[UIApplication sharedApplication] openURL:url];
        }] ;
    }] ;
    
    [self.lbService bk_whenTapped:^{
        [weakSelf.lbService oct_buttonClickAnimationComplete:^{
            NSString *urlStr = @"https://shimo.im/octopus#/terms" ;
            NSURL *url = [NSURL URLWithString:urlStr] ;
            [[UIApplication sharedApplication] openURL:url];
        }] ;
    }] ;
}

- (IBAction)replyAction:(id)sender {
    // https://shimo.im/forms/bvVAXVnavgjCjqm7/fill 小章鱼移动端问题反馈
    NSString *urlStr = @"https://fankui.shimo.im/?type=create&tags[]=5cd3dc0c27f63b001104c052" ;
    NSURL *url = [NSURL URLWithString:urlStr] ;
    [[UIApplication sharedApplication] openURL:url];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)xt_cellHeight {
    return 460. ;
}

@end
