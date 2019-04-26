//
//  HomeEmptyPHView.m
//  Notebook
//
//  Created by teason23 on 2019/4/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeEmptyPHView.h"
#import "MDThemeConfiguration.h"
#import "NoteBooks.h"
#import "XTCloudHandler.h"
#import <ReactiveObjC/ReactiveObjC.h>

#define HE_oceanList    @[@"🐙",@"🐢",@"🦂",@"🦀",@"🦑",@"🦐",@"🐠",@"🐟",@"🐬",@"🐡",@"🦈",@"🐳",@"🐋",@"🐊"]

@implementation HomeEmptyPHView


- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
    self.imgIcon.xt_theme_imageColor = k_md_iconColor ;
    self.area.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbPh.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .6) ;
    
    self.area.layer.cornerRadius = 10 ;
    self.area.xt_borderColor = [UIColor colorWithRed:51./255.0 green:51./255.0 blue:51./255.0 alpha:0.06] ;
    self.area.xt_borderWidth = .5 ;
    
    self.area.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.06].CGColor;
    self.area.layer.shadowOffset = CGSizeMake(0,4) ;
    self.area.layer.shadowOpacity = 40 ;
    self.area.layer.shadowRadius = .06 ;
    
    @weakify(self)
    [[RACSignal interval:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        
        @strongify(self)
        [self start] ;
    }] ;
    
}


- (void)start {
    
    [UIView transitionWithView:self.lbTitle duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        if (!self.isMark) {
            self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
            self.lbTitle.text = [self welcomeString] ;
            self.lbTitle.font = [UIFont boldSystemFontOfSize:27] ;
        }
        else {
            switch (self.book.vType) {
                case Notebook_Type_recent:
                case Notebook_Type_notebook: {
                    self.lbTitle.text = @"还没有任何笔记" ;
                    self.lbTitle.font = [UIFont systemFontOfSize:18] ;
                    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
                }
                    break;
                case Notebook_Type_staging: {
                    self.lbTitle.text = @"不在笔记本中的笔记将放到这里" ;
                    self.lbTitle.font = [UIFont systemFontOfSize:18] ;
                    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .3) ;
                }
                    break;
                default:
                    break;
            }
        }
        
        self.isMark = !self.isMark ;
        
    } completion:^(BOOL finished) {
        
    }] ;
    
    [UIView transitionWithView:self.lbEmoji duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        NSArray *oList = HE_oceanList ;
        int random = arc4random() % oList.count ;
        self.lbEmoji.text = oList[random] ;
        
    } completion:^(BOOL finished) {
        
    }] ;
}


- (NSString *)welcomeString {
    NSString *dateStr = [[NSDate date] xt_getStrWithFormat:@"HH"] ;
    int hour = [dateStr intValue] ;
    if (hour >= 4 && hour < 12) {
        dateStr = @"早上好" ;
    }
    else if (hour >= 12 && hour < 18) {
        dateStr = @"下午好" ;
    }
    else if (hour >= 18 && hour < 24) {
        dateStr = @"晚上好" ;
    }
    else if (hour >= 0 && hour < 4) {
        dateStr = @"深夜好" ;
    }
    
    return XT_STR_FORMAT(@"%@，%@",dateStr, [XTIcloudUser userInCacheSyncGet].givenName) ;
}

 




@end
