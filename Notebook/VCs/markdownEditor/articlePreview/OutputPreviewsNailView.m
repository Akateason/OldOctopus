//
//  OutputPreviewsNailView.m
//  Notebook
//
//  Created by teason23 on 2019/5/10.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OutputPreviewsNailView.h"
#import <XTlib/XTlib.h>
#import "XTCloudHandler.h"
#import "MDThemeConfiguration.h"


@implementation OutputPreviewsNailView

+ (OutputPreviewsNailView *)makeANail {
    OutputPreviewsNailView *view = [OutputPreviewsNailView new] ;
    view.frame = CGRectMake(0, 0, APP_WIDTH, 120) ;
    
    UILabel *lbName = [UILabel new] ;
    lbName.text = [XTIcloudUser userInCacheSyncGet].name ;
    lbName.font = [UIFont systemFontOfSize:21] ;
    lbName.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    lbName.textAlignment = NSTextAlignmentRight ;
    [view addSubview:lbName] ;
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(36) ;
        make.right.equalTo(view).offset(-30) ;
    }] ;
    
    UILabel *lbDetail = [UILabel new] ;
    lbDetail.text = XT_STR_FORMAT(@"于 %@ 写于小章鱼笔记", [[NSDate date] xt_getStrWithFormat:@"YYYY.MM.dd"] ) ;
    lbDetail.font = [UIFont systemFontOfSize:16] ;
    lbDetail.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    lbDetail.textAlignment = NSTextAlignmentRight ;
    [view addSubview:lbDetail] ;
    [lbDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom).offset(5) ;
        make.right.equalTo(view).offset(-30) ;
    }] ;
    
    return view ;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
