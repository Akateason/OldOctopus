//
//  MDEditUrlView.m
//  Notebook
//
//  Created by teason23 on 2019/3/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDEditUrlView.h"
#import <XTlib/XTlib.h>
#import "MdInlineModel.h"

@implementation MDEditUrlView

- (IBAction)confirmOnClick:(id)sender {
    self.blk(YES, self.tfTitle.text, self.tfUrl.text) ;
}

- (IBAction)cancelOnClick:(id)sender {
    self.blk(NO, nil, nil) ;
}


+ (void)showOnView:(UITextView *)editor
            window:(UIWindow *)window
             model:(MarkdownModel *)model
    keyboardHeight:(CGFloat)keyboardHeight
          callback:(CallbackBlk)blk {
    
    MDEditUrlView *urlView = [MDEditUrlView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    urlView.xt_cornerRadius = 8 ;
    
    UIView *hud = [UIView new] ;
    hud.backgroundColor = [UIColor colorWithWhite:0 alpha:.8] ;
    [window addSubview:hud] ;
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window) ;
    }] ;
    
    [hud addSubview:urlView] ;
    [urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(hud).offset(20) ;
        make.right.equalTo(hud).offset(-20) ;
        make.height.equalTo(@328) ;
        make.bottom.equalTo(window.mas_bottom).offset(- keyboardHeight) ;
    }] ;

    if (model && model.type == MarkdownInlineLinks) {
        MdInlineModel *inlineModel = (MdInlineModel *)model ;
        urlView.tfTitle.text = inlineModel.linkTitle ;
        urlView.tfUrl.text = inlineModel.linkUrl ;
    }
    [urlView.tfTitle becomeFirstResponder] ;
    
    @weakify(urlView)
    urlView.blk = ^(BOOL isConfirm, NSString *title, NSString *url) {
        @strongify(urlView)
        [urlView removeFromSuperview] ;
        [hud removeFromSuperview] ;
        blk(isConfirm,title,url) ;
    } ;
}




@end
