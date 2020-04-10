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

#import "MarkdownModel.h"
#import "OctToolbar.h"

@implementation OctToolbarBlockView

- (void)renderWithTypeList:(NSArray *)typeList {
    BOOL hasCodeBlkSerious = NO ;
    for (NSNumber *num in typeList) {
        switch ([num intValue]) {
            case MarkdownSyntaxULLists: self.btUlist.selected = YES; break ;
            case MarkdownSyntaxOLLists: self.btOlist.selected = YES; break ;
            case MarkdownSyntaxTaskLists: self.btTaskList.selected = YES; break ;
            case MarkdownSyntaxBlockquotes: self.btQuote.selected = YES; break ;
            case MarkdownSyntaxHr: self.btSepline.selected = YES; break ;
            default:
                break;
        }
        
        if ([num intValue] == MarkdownSyntaxCodeBlock) hasCodeBlkSerious = YES ;
    }
    
    self.btCodeBlock.enabled =
    self.btMath.enabled =
    self.btQuote.enabled =
    self.btTable.enabled =
    self.btHtml.enabled =
    self.btVegaChart.enabled =
    self.btFlowChart.enabled =
    self.btSequnceDiag.enabled =
    self.btMermaid.enabled =
    self.btUlist.enabled =
    self.btOlist.enabled =
    self.btTaskList.enabled =
    self.btLeftTab.enabled =
    self.btRightTabg.enabled =
    !hasCodeBlkSerious ;
}


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
    
    for (UIView *area in self.areas) {
        area.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_bgColor) ;
        area.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .06) ;
        area.xt_borderWidth = .5 ;
        area.xt_cornerRadius = 6 ;
        area.xt_maskToBounds = YES ;
    }
    self.xt_theme_backgroundColor = k_md_backColor ;
    

    
    WEAK_SELF
    [self.btUlist xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectUList] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btOlist xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectOrderlist] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btLeftTab xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectLeftTab] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btRightTabg xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectRightTab] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btTaskList xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectTaskList] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btQuote xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectQuoteBlock] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btSepline xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectSepLine] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btCodeBlock xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectCodeBlock] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btMath xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectMathBlock] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btTable xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectTable] ;
        [weakSelf.scrollView removeFromSuperview] ;
    } forControlEvents:UIControlEventTouchUpInside] ;

    [self.btHtml xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectHtml] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btVegaChart xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectVegaChart] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btFlowChart xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectFlowChart] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btSequnceDiag xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectSequnceDiag] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btMermaid xt_addEventHandler:^(UIButton *sender) {

        [weakSelf.blkBoard_Delegate toolbarDidSelectMermaid] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
}

- (void)addMeAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight {
    [self scrollView] ;
    UIView *backView = [UIView new] ;
    
    for (UIView *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            
            [window addSubview:self.scrollView] ;
            [self.scrollView addSubview:backView] ;
            [backView addSubview:self] ;
            
            [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(window) ;
                make.height.equalTo(@(keyboardHeight - OctToolbarHeight)) ;
            }] ;
            
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.scrollView) ;
            }] ;
            
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(backView);
                make.width.equalTo(@(APP_WIDTH));
                make.height.equalTo(@325) ;
            }] ;
            
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.mas_bottom) ;
            }] ;

        }
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init] ;
        scrollView.xt_theme_backgroundColor = k_md_backColor ;
        _scrollView = scrollView ;
    }
    return _scrollView ;
}

@end
