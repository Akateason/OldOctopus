//
//  SingleGuidVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SingleGuidVC.h"
#import "MDThemeConfiguration.h"
#import <XTlib/XTlib.h>
#import <BlocksKit+UIKit.h>

@interface SingleGuidVC ()


@end

@implementation SingleGuidVC

+ (instancetype)getMeWithType:(int)type {
    SingleGuidVC *guid1 = [SingleGuidVC getCtrllerFromNIB] ;
    guid1.viewType = type ;
    return guid1 ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.lb1.textColor = [[MDThemeConfiguration sharedInstance] themeColor:k_md_themeColor] ;
    self.lb2.textColor = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, .5)] ;
    self.view.backgroundColor = [UIColor whiteColor] ;
    
    
    if (self.viewType == 1) {
        _img.image = [UIImage imageNamed:@"guiding_img_1"] ;
        _lb1.text = @"支持 Markdown 编写" ;
        _lb2.text = @"轻量化，易读易写的纯文本格式编写文档\n支持图片，图表、数学式" ;
        self.btStart.hidden = YES ;
    }
    else if (self.viewType == 2) {
        self.img.image = [UIImage imageNamed:@"guiding_img_2"] ;
        self.lb1.text = @"多端同步实时存储" ;
        self.lb2.text = @"iCloud一键登录\nMac 与 iPhone 内容实时同步存储" ;
        self.btStart.hidden = YES ;
    }
    else {
        UIView *graidentView = [UIView new] ;
        graidentView.frame = self.btStart.frame ;
        graidentView.xt_gradientPt0 = CGPointMake(0, .5) ;
        graidentView.xt_gradientPt1 = CGPointMake(1, .5) ;
        graidentView.xt_gradientColor0 = UIColorHex(@"fe4241") ;
        graidentView.xt_gradientColor1 = UIColorHex(@"fe8c68") ;
        graidentView.xt_completeRound = YES ;
        [self.view insertSubview:graidentView belowSubview:self.btStart] ;
        [graidentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.btStart) ;
        }] ;
        self.btStart.textColor = [UIColor whiteColor] ;
        self.btStart.userInteractionEnabled = YES ;

        
        self.btStart.userInteractionEnabled = YES ;
        WEAK_SELF
        [self.btStart bk_whenTapped:^{
            [weakSelf.delegate startOnClick] ;
        }] ;

    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
