//
//  OctToolbarBlockView.m
//  Notebook
//
//  Created by teason23 on 2019/5/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctToolbarBlockView.h"
#import "KeyboardViewButton.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import <BlocksKit+UIKit.h>
#import "MarkdownModel.h"

@implementation OctToolbarBlockView

- (void)renderWithModel:(MarkdownModel *)model {
    switch (model.type) {
        case MarkdownSyntaxULLists: self.btUlist.selected = YES; break ;
        case MarkdownSyntaxOLLists: self.btOlist.selected = YES; break ;
        case MarkdownSyntaxTaskLists: self.btTaskList.selected = YES; break ;
        case MarkdownSyntaxBlockquotes: self.btQuote.selected = YES; break ;
        case MarkdownSyntaxHr: self.btSepline.selected = YES; break ;
        case MarkdownSyntaxMultipleMath: self.btMath.selected = YES; break ;
        case MarkdownSyntaxCodeBlock: self.btCodeBlock.selected = YES; break ;
            
        default:
            break;
    }
}

- (void)clearUI {
    self.btUlist.selected = NO ;
    self.btOlist.selected = NO ;
    self.btLeftTab.selected = NO ;
    self.btRightTabg.selected = NO ;
    self.btTaskList.selected = NO ;
    self.btQuote.selected = NO ;
    self.btSepline.selected = NO ;
    self.btMath.selected = NO ;
    self.btCodeBlock.selected = NO ;
    self.btTable.selected = NO ;
    self.btHtml.selected = NO ;
    self.btVegaChart.selected = NO ;
    self.btFlowChart.selected = NO ;
    self.btSequnceDiag.selected = NO ;
    self.btMermaid.selected = NO ;
}

- (void)awakeFromNib {
    [super awakeFromNib] ;
    
    self.area1.backgroundColor = [UIColor whiteColor] ;
    self.area2.backgroundColor = [UIColor whiteColor] ;
    self.area3.backgroundColor = [UIColor whiteColor] ;
    self.area4.backgroundColor = [UIColor whiteColor] ;
    self.area5.backgroundColor = [UIColor whiteColor] ;
    self.area6.backgroundColor = [UIColor whiteColor] ;
    self.area7.backgroundColor = [UIColor whiteColor] ;
    self.area8.backgroundColor = [UIColor whiteColor] ;
    
    self.area1.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area2.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area3.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area4.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area5.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area6.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area7.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    self.area8.xt_borderColor = UIColorRGBA(24, 18, 17, .1) ;
    
    self.area1.xt_borderWidth = .5 ;
    self.area2.xt_borderWidth = .5 ;
    self.area3.xt_borderWidth = .5 ;
    self.area4.xt_borderWidth = .5 ;
    self.area5.xt_borderWidth = .5 ;
    self.area6.xt_borderWidth = .5 ;
    self.area7.xt_borderWidth = .5 ;
    self.area8.xt_borderWidth = .5 ;
    
    self.area1.xt_cornerRadius = 6 ;
    self.area2.xt_cornerRadius = 6 ;
    self.area3.xt_cornerRadius = 6 ;
    self.area4.xt_cornerRadius = 6 ;
    self.area5.xt_cornerRadius = 6 ;
    self.area6.xt_cornerRadius = 6 ;
    self.area7.xt_cornerRadius = 6 ;
    self.area8.xt_cornerRadius = 6 ;
    
    self.backgroundColor = UIColorHex(@"f9f6f6") ;
    
    
    WEAK_SELF
    [self.btUlist bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectUList] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btOlist bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectOrderlist] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btLeftTab bk_addEventHandler:^(UIButton *sender) {
//        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectLeftTab] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btRightTabg bk_addEventHandler:^(UIButton *sender) {
//        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectRightTab] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btTaskList bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectTaskList] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btQuote bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectQuoteBlock] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btSepline bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectSepLine] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btCodeBlock bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectCodeBlock] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btMath bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectMathBlock] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btTable bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectTable] ;
        [weakSelf removeFromSuperview] ;
    } forControlEvents:UIControlEventTouchUpInside] ;

    [self.btHtml bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectHtml] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btVegaChart bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectVegaChart] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btFlowChart bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectFlowChart] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btSequnceDiag bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectSequnceDiag] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btMermaid bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.selected ;
        [weakSelf.blkBoard_Delegate toolbarDidSelectMermaid] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
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
