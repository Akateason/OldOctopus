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


@implementation IAPPayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_drawerSelectedColor ;
    self.lbMonth.xt_theme_textColor = self.lbYear.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.btMonth.xt_theme_textColor = self.btYear.xt_theme_textColor = k_md_drawerSelectedColor ;
    self.btMonth.xt_theme_backgroundColor = self.btYear.xt_theme_backgroundColor = k_md_themeColor ;
    self.btMonth.xt_cornerRadius = self.btYear.xt_cornerRadius = 6. ;
    self.lbDescYear.xt_theme_textColor = self.lbDescMonth.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    
    
    self.iap = [IapUtil new] ;
    
    WEAK_SELF
    [[XTIAP sharedInstance] requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
        
        if (response > 0 ) {
            NSArray<SKProduct *> *products = response.products ;
            for (SKProduct *product in products) {
                
                if ([product.productIdentifier isEqualToString:k_IAP_ID_MONTH]) {
                    NSString *title = XT_STR_FORMAT(@"%@ 每月",[[XTIAP sharedInstance] getLocalePrice:product]) ;
                    [weakSelf.btMonth setTitle:title forState:0] ;
                }
                else if ([product.productIdentifier isEqualToString:k_IAP_ID_YEAR]) {
                    NSString *title = XT_STR_FORMAT(@"%@ 每年",[[XTIAP sharedInstance] getLocalePrice:product]) ;
                    [weakSelf.btYear setTitle:title forState:0] ;
                }
            }
        }
    }] ;            
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (CGFloat)xt_cellHeight {
    return 127. ;
}

- (IBAction)btMonthAction:(UIButton *)sender {
    [sender oct_buttonClickAnimationWithScale:1.1 complete:^{
        [[OctMBPHud sharedInstance] show] ;
        
        [self.iap buy:k_IAP_ID_MONTH] ;
    }] ;
}

- (IBAction)btYearAction:(UIButton *)sender {
    [sender oct_buttonClickAnimationWithScale:1.1 complete:^{
        [[OctMBPHud sharedInstance] show] ;
    
        [self.iap buy:k_IAP_ID_YEAR] ;
    }] ;
}



@end
