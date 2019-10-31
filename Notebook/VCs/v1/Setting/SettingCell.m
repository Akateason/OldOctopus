//
//  SettingCell.m
//  Notebook
//
//  Created by teason23 on 2019/6/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SettingCell.h"
#import "MDThemeConfiguration.h"
#import <BlocksKit+UIKit.h>
#import "SetGeneralVC.h"
#import "SetThemeVC.h"
#import "SetEditorVC.h"
#import <SafariServices/SafariServices.h>
#import "IAPSubscriptionVC.h"
#import "IapUtil.h"
#import "IAPSuccessSubscriptionVC.h"
#import "XTCloudHandler.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SetTrashVC.h"
#import "AppDelegate.h"

@implementation SettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.act.hidden = YES ;
    self.selectionStyle = 0 ;
    self.xt_theme_backgroundColor = k_md_bgColor ; //k_md_drawerSelectedColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .9) ;
    self.rightTip.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.icon.xt_theme_imageColor = XT_MAKE_theme_color(k_md_iconColor, .8) ;
    
    self.topLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    self.bottomLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
    WEAK_SELF
    [self bk_whenTapped:^{
        
        [weakSelf.icon oct_buttonClickAnimationComplete:^{
            [weakSelf cellDidSelect] ;
        }] ;
        
    }] ;
}

- (void)cellDidSelect {
    
    NSInteger section = self.xt_indexPath.section ;
    NSInteger row = self.xt_indexPath.row ;
    NSDictionary *dic = self.xt_model ;
    NSString *title = dic[@"t"] ;
    if ([title containsString:@"通用"]) {
        SetGeneralVC *vc = [SetGeneralVC getMe] ;
        [self.xt_navigationController pushViewController:vc animated:YES] ;
    }
    else if ([title containsString:@"主题"]) {
        SetThemeVC *vc = [SetThemeVC getMe] ;
        [self.xt_navigationController pushViewController:vc animated:YES] ;
    }
    else if ([title containsString:@"编辑器"]) {
        SetEditorVC *vc = [SetEditorVC getMe] ;
        [self.xt_navigationController pushViewController:vc animated:YES] ;
    }
    else if ([title containsString:@"反馈"]) {
        // https://shimo.im/forms/bvVAXVnavgjCjqm7/fill 小章鱼移动端问题反馈
        NSString *urlStr = @"https://fankui.shimo.im/?type=create&tags[]=5cd3dc0c27f63b001104c052" ;
        NSURL *url = [NSURL URLWithString:urlStr] ;
        [[UIApplication sharedApplication] openURL:url];
    }
    else if ([title containsString:@"订阅"]) {
        if ([XTIcloudUser hasLogin]) {
            [IapUtil iapVipUserIsValid:^(BOOL isValid) {
                
                if (k_Subscript_Test_On) { // 测试连续订阅
                    IAPSubscriptionVC *vc = [IAPSubscriptionVC getMe] ;
                    [self.xt_navigationController pushViewController:vc animated:YES] ;
                    
                    return ;
                }
                
                if (isValid) {
                    IAPSuccessSubscriptionVC *vc = [IAPSuccessSubscriptionVC getMe] ;
                    [self.xt_navigationController pushViewController:vc animated:YES] ;
                }
                else {
                    IAPSubscriptionVC *vc = [IAPSubscriptionVC getMe] ;
                    [self.xt_navigationController pushViewController:vc animated:YES] ;
                }
            }] ;
        }
        else {
            IAPSubscriptionVC *vc = [IAPSubscriptionVC getMe] ;
            [self.xt_navigationController pushViewController:vc animated:YES] ;

            
        }
    }
    else if ([title containsString:@"垃圾"]) {
        [SetTrashVC showFromCtller:self.xt_viewController] ;
    }
    else if ([title containsString:@"同步"]) {
        if (![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist]) {
            IAPSubscriptionVC *vc = [IAPSubscriptionVC getMe] ;
            [self.xt_navigationController pushViewController:vc animated:YES] ;
            
            return ;
        }
        
        self.act.hidden = NO ;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate ;
        [self.act startAnimating] ;
        WEAK_SELF
        [appDelegate.launchingEvents pullAllComplete:^{
            [weakSelf.act stopAnimating] ;
            weakSelf.act.hidden = YES ;
        }] ;
    }
}

+ (CGFloat)xt_cellHeight {
    return 50. ;
}

- (void)xt_configure:(NSDictionary *)model indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:model indexPath:indexPath] ;
    
    self.icon.image = [UIImage imageNamed:model[@"p"]] ;
    NSString *title = model[@"t"] ;
    self.lbTitle.text = title ;
    self.rightTip.text = model[@"r"] ;
    self.rightCorner.hidden = NO ;
    
    if ([title containsString:@"订阅"]) {
        WEAK_SELF
        [IapUtil iapVipUserIsValid:^(BOOL isValid) {
            weakSelf.rightTip.text = isValid ? @"已订阅" : model[@"r"] ;
        }] ;
    }
    else if ([title containsString:@"垃圾桶"]) {
        self.rightTip.text = XT_STR_FORMAT(@"%d",[Note xt_countWhere:@"isDeleted == 1 AND icRecordName NOT LIKE 'mac-note%%'"]) ;
    }
    else if ([title containsString:@"主题"]) {
        self.rightTip.text = [MDThemeConfiguration sharedInstance].currentFormatLanguage ;
    }
    else if ([title containsString:@"同步"]) {
        [IapUtil iapVipUserIsValid:^(BOOL isValid) {
            if (!isValid) self.rightTip.text = @"Pro" ;
        }] ;
        self.rightCorner.hidden = YES ;
    }
}

- (void)setSepLineMode:(SettingCellSeperateLine_Mode)sepLineMode {
    switch (sepLineMode) {
        case SettingCellSeperateLine_Mode_ALL_FULL:{
            self.topLine.hidden = self.bottomLine.hidden = NO ;
            self.left_topLine.constant = 0 ;
        }
            break;
        case SettingCellSeperateLine_Mode_Top: {
            self.topLine.hidden = NO ;
            self.bottomLine.hidden = YES ;
            self.left_topLine.constant = 0 ;
        }
            break;
        case SettingCellSeperateLine_Mode_Bottom: {
            self.topLine.hidden = self.bottomLine.hidden = NO ;
            self.left_topLine.constant = 25 ;
        }
            break ;
        case SettingCellSeperateLine_Mode_Middel: {
            self.topLine.hidden = NO ;
            self.bottomLine.hidden = YES ;
            self.left_topLine.constant = 25 ;
        }
            break ;
        default:
            break;
    }
}

@end
