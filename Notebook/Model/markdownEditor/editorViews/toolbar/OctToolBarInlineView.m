//
//  OctToolBarInlineView.m
//  Notebook
//
//  Created by teason23 on 2019/5/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctToolBarInlineView.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "MarkdownModel.h"
#import "KeyboardViewButton.h"

@implementation OctToolBarInlineView

- (void)renderWithModel:(MarkdownModel *)model {
    switch (model.type) {
        case MarkdownSyntaxHeaders: {
            long markCount = [[[model.str componentsSeparatedByString:@""] firstObject] xt_searchAllRangesWithText:@"#"].count ;
            switch (markCount) {
                case 1: self.bth1.selected = YES; break;
                case 2: self.bth2.selected = YES; break;
                case 3: self.bth3.selected = YES; break;
                case 4: self.bth4.selected = YES; break;
                case 5: self.bth5.selected = YES; break;
                case 6: self.bth6.selected = YES; break;
                default: break;
            }
        }
            break;
        case -1: self.btParaClean.selected = YES; break;
        case MarkdownInlineBold: self.btBold.selected = YES ; break ;
        case MarkdownInlineItalic: self.btItalic.selected = YES ; break ;
        case MarkdownInlineBoldItalic: {
            self.btBold.selected = YES ;
            self.btItalic.selected = YES ;
        } break ;
        case MarkdownInlineDeletions: self.btDeletion.selected = YES ; break ;
        case MarkdownInlineInlineCode: self.btInlineCode.selected = YES ; break ;
        case MarkdownInlineLinks: self.btLink.selected = YES ; break ;
            
        default:
            break;
    }
}

- (void)clearUI {
    self.btBold.selected = NO ;
    self.btItalic.selected = NO ;
    self.btDeletion.selected = NO ;
    self.btInlineCode.selected = NO ;
    self.bth1.selected = NO ;
    self.bth2.selected = NO ;
    self.bth3.selected = NO ;
    self.bth4.selected = NO ;
    self.bth5.selected = NO ;
    self.bth6.selected = NO ;
    self.btParaClean.selected = NO ;
    self.btLink.selected = NO ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.area1.backgroundColor = [UIColor whiteColor] ;
    self.area2.backgroundColor = [UIColor whiteColor] ;
    self.area3.backgroundColor = [UIColor whiteColor] ;
    self.area4.backgroundColor = [UIColor whiteColor] ;
    self.area5.backgroundColor = [UIColor whiteColor] ;
    self.area6.backgroundColor = [UIColor whiteColor] ;
    
    self.area1.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area2.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area3.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area4.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area5.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area6.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    
    self.area1.xt_borderWidth = .5 ;
    self.area2.xt_borderWidth = .5 ;
    self.area3.xt_borderWidth = .5 ;
    self.area4.xt_borderWidth = .5 ;
    self.area5.xt_borderWidth = .5 ;
    self.area6.xt_borderWidth = .5 ;
    
    self.area1.xt_cornerRadius = 6 ;
    self.area2.xt_cornerRadius = 6 ;
    self.area3.xt_cornerRadius = 6 ;
    self.area4.xt_cornerRadius = 6 ;
    self.area5.xt_cornerRadius = 6 ;
    self.area6.xt_cornerRadius = 6 ;
    
    self.backgroundColor = UIColorHex(@"f9f6f6") ;
    
    
    
    
    WEAK_SELF
    [self.btBold xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectBold] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btItalic xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectItalic] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btDeletion xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectDeletion] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btInlineCode xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectInlineCode] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth1 xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectH1] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth2 xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectH2] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth3 xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectH3] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth4 xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectH4] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth5 xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectH5] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth6 xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectH6] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btParaClean xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectClearToCleanPara] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btLink xt_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.inlineBoard_Delegate toolbarDidSelectLink] ;
        [weakSelf removeFromSuperview] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
}

- (void)addMeAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight {
    for (UIView *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            [window addSubview:self] ;
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(window) ;
                make.height.equalTo(@(keyboardHeight - 40)) ;
            }] ;
        }
    }
}

@end
