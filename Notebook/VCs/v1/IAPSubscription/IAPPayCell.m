//
//  IAPPayCell.m
//  Notebook
//
//  Created by teason23 on 2019/7/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "IAPPayCell.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "OctMBPHud.h"
#import <XTIAP/XTIAP.h>
#import "OctRequestUtil.h"

@implementation IAPPayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbMonth.xt_theme_textColor = self.lbYear.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btMonth.xt_theme_textColor = self.btYear.xt_theme_textColor = k_md_backColor ;
    self.btMonth.xt_theme_backgroundColor = self.btYear.xt_theme_backgroundColor = k_md_themeColor ;
    self.btMonth.xt_cornerRadius = self.btYear.xt_cornerRadius = 6. ;
    self.lbDescYear.xt_theme_textColor = self.lbDescMonth.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.baseLien.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    
    NSString *restoreStr = @"如果已经订阅, 请恢复购买";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:restoreStr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) range:NSMakeRange(0, 7)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:XT_GET_MD_THEME_COLOR_KEY_A(k_md_themeColor,1) range:NSMakeRange(8, 5)];
    self.lbRestore.attributedText = attrStr ;
    self.lbRestore.userInteractionEnabled = YES ;
    
    [self.lbRestore bk_whenTapped:^{
        
        if (![XTIcloudUser hasLogin]) {
//            [SVProgressHUD showInfoWithStatus:@"请登录"] ;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[XTCloudHandler sharedInstance] alertCallUserToIcloud:self.xt_viewController] ;
            }) ;
            
            return ;
        }
        else {                        
            [OctRequestUtil restoreOnServer] ;
        }
                                
    }] ;
    
    self.iap = [IapUtil new] ;
    
    WEAK_SELF
    [[XTIAP sharedInstance] requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
        
        if (response > 0 ) {
            NSArray<SKProduct *> *products = response.products ;
            for (SKProduct *product in products) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *price = [[XTIAP sharedInstance] getLocalePrice:product] ;
                    if ([product.productIdentifier isEqualToString:k_IAP_ID_MONTH]) {
                        NSString *title = XT_STR_FORMAT(@"%@ 每月", price) ;
                        [weakSelf.btMonth setTitle:title forState:0] ;
                        
                        NSString *desc = XT_STR_FORMAT(@"试用1周，之后%@每月",price) ;
                        [weakSelf.lbDescMonth setText:desc] ;
                    }
                    else if ([product.productIdentifier isEqualToString:k_IAP_ID_YEAR]) {
                        NSString *title = XT_STR_FORMAT(@"%@ 每年", price) ;
                        [weakSelf.btYear setTitle:title forState:0] ;
                        
                        NSString *desc = XT_STR_FORMAT(@"试用1个月，之后%@每年",price) ;
                        [weakSelf.lbDescYear setText:desc] ;
                    }
                    
                }) ;
            }
        }
    }] ;            
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (CGFloat)xt_cellHeight {
    return 160. ;
}

- (IBAction)btMonthAction:(UIButton *)sender {
    [sender oct_buttonClickAnimationWithScale:1.1 complete:^{
        if (![XTIcloudUser hasLogin]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[XTCloudHandler sharedInstance] alertCallUserToIcloud:self.xt_viewController] ;
            }) ;
            
//            return ;
        }
        else {
            [[OctMBPHud sharedInstance] show] ;
            
            [self.iap buy:k_IAP_ID_MONTH] ;
        }
        
    }] ;
}

- (IBAction)btYearAction:(UIButton *)sender {
    [sender oct_buttonClickAnimationWithScale:1.1 complete:^{
        if (![XTIcloudUser hasLogin]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[XTCloudHandler sharedInstance] alertCallUserToIcloud:self.xt_viewController] ;
            }) ;
        }
        else {
            [[OctMBPHud sharedInstance] show] ;
            
            [self.iap buy:k_IAP_ID_YEAR] ;
        }
                
    }] ;
}



@end
