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
#import <BlocksKit+UIKit.h>
#import "MarkdownModel.h"
#import "KeyboardViewButton.h"

@implementation OctToolBarInlineView

- (void)renderWithlist:(NSArray *)list {
    BOOL isCodeBlkSerous = NO ;
    for (NSNumber *num in list) {
        int type = [num intValue] ;
        switch (type) {
            case MarkdownSyntaxH1: self.bth1.selected = YES; break;
            case MarkdownSyntaxH2: self.bth2.selected = YES; break;
            case MarkdownSyntaxH3: self.bth3.selected = YES; break;
            case MarkdownSyntaxH4: self.bth4.selected = YES; break;
            case MarkdownSyntaxH5: self.bth5.selected = YES; break;
            case MarkdownSyntaxH6: self.bth6.selected = YES; break;
            case MarkdownSyntaxUnknown: self.btParaClean.selected = YES; break;
            case MarkdownInlineBold: self.btBold.selected = YES ; break ;
            case MarkdownInlineItalic: self.btItalic.selected = YES ; break ;
            case MarkdownInlineDeletions: self.btDeletion.selected = YES ; break ;
            case MarkdownInlineInlineCode: self.btInlineCode.selected = YES ; break ;
            case MarkdownInlineLinks: self.btUnderline.selected = YES ; break ;
            default:
                break;
        }
        
        if (type == MarkdownSyntaxCodeBlock) isCodeBlkSerous = YES ;
    }
    
    self.bth1.enabled =
    self.bth2.enabled =
    self.bth3.enabled =
    self.bth4.enabled =
    self.bth5.enabled =
    self.bth6.enabled =
    self.btParaClean.enabled =
    self.btBold.enabled =
    self.btItalic.enabled =
    self.btDeletion.enabled =
    self.btInlineCode.enabled =
    self.btUnderline.enabled =
    !isCodeBlkSerous ;
}

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
        case MarkdownInlineLinks: self.btUnderline.selected = YES ; break ;
            
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
    self.btUnderline.selected = NO ;
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
    [self.btBold bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectBold] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btItalic bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectItalic] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btDeletion bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectDeletion] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btInlineCode bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectInlineCode] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth1 bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectH1] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth2 bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectH2] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth3 bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectH3] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth4 bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectH4] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth5 bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectH5] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.bth6 bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectH6] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btParaClean bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectClearToCleanPara] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.btUnderline bk_addEventHandler:^(UIButton *sender) {

        [weakSelf.inlineBoard_Delegate toolbarDidSelectUnderline] ;
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
