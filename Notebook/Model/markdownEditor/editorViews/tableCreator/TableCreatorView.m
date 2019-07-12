//
//  TableCreatorView.m
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "TableCreatorView.h"
#import <XTlib/XTlib.h>
#import <BlocksKit+UIKit.h>

@implementation TableCreatorView

+ (void)showOnView:(UIView *)onView
            window:(UIWindow *)window
    keyboardHeight:(CGFloat)keyboardHeight
          callback:(CallbackBlk)blk {
    
    TableCreatorView *creator = [TableCreatorView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    creator.xt_cornerRadius = 8 ;
    
    UIView *hud = [UIView new] ;
    hud.backgroundColor = [UIColor colorWithWhite:0 alpha:.8] ;
    [window addSubview:hud] ;
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window) ;
    }] ;
    
    [hud addSubview:creator] ;
    [creator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(hud).offset(20) ;
        make.right.equalTo(hud).offset(-20) ;
        make.height.equalTo(@200) ;
        make.bottom.equalTo(window.mas_bottom).offset(- keyboardHeight) ;
    }] ;

    [creator.tfLineCount becomeFirstResponder] ;
    
    @weakify(creator)
    creator.blk = ^(BOOL isConfirm, NSString *line, NSString *column) {
        @strongify(creator)
        [creator removeFromSuperview] ;
        [hud removeFromSuperview] ;
        blk(isConfirm,line,column) ;
    } ;

}

- (IBAction)okAction:(id)sender {
    self.blk(YES, self.tfLineCount.text, self.tfColumnCount.text) ;
}

- (IBAction)cancelAction:(id)sender {
    self.blk(NO, nil, nil) ;
}


- (void)awakeFromNib {
    [super awakeFromNib] ;
    _tfLineCount.placeholder = @"2" ;
    _tfColumnCount.placeholder = @"3" ;
}


@end
