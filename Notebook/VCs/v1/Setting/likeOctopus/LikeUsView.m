//
//  LikeUsView.m
//  Notebook
//
//  Created by teason23 on 2019/12/31.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LikeUsView.h"
#import "AppstoreCommentUtil.h"

@implementation LikeUsView

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.hud.xt_cornerRadius = 12.0 ;
    self.hud.xt_maskToBounds = YES ;
    self.lb5Star.textColor = UIColorHex(@"0090ff") ;
    [self.btReply setTitleColor:UIColorHex(@"0090ff") forState:0] ;
    [self.btLater setTitleColor:UIColorHex(@"0090ff") forState:0] ;
    
    self.sep1.backgroundColor = self.sep2.backgroundColor = self.sep3.backgroundColor = [UIColor colorWithWhite:0 alpha:.3] ;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.2] ;
    
    WEAK_SELF
    [self.btLater xt_whenTapped:^{
        [weakSelf removeFromSuperview] ;
    }];
    
    [self.btReply xt_whenTapped:^{
        NSString *urlStr = @"https://fankui.shimo.im/?type=create&tags[]=5cd3dc0c27f63b001104c052" ;
        NSURL *url = [NSURL URLWithString:urlStr] ;
        [[UIApplication sharedApplication] openURL:url];
        
//        [AppstoreCommentUtil sendMailForReplyBugsFromCtrller:weakSelf.xt_viewController] ;
        
        [weakSelf removeFromSuperview] ;
    }];
    
    self.goStoreView.userInteractionEnabled = YES ;
    [self.goStoreView xt_whenTapped:^{
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1455174888"] ;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
        [weakSelf removeFromSuperview] ;
    }];
    
    [self.btBackground xt_whenTapped:^{
        [weakSelf removeFromSuperview] ;
    }] ;
    
}




@end
