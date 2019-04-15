//
//  MDToolbar.m
//  Notebook
//
//  Created by teason23 on 2019/3/22.
//  Copyright © 2019 teason23. All rights reserved.
//
//

#import "MDToolbar.h"
#import <BlocksKit+UIKit.h>
#import <XTlib/XTlib.h>
#import <XTlib/XTSIAlertView.h>
#import "MarkdownModel.h"

static const float kFlexOfButtons = 20 ;
static const float kMarginOfButtons = 10 ;
static const int kTagOfButton = 88390 ;

@interface MDToolbar ()
@property (strong, nonatomic) UIScrollView *scrollview ;
@end

@implementation MDToolbar

// H - // B I U S // photo link // ul ol tl // code quote // undo redo //
- (instancetype)initWithConfigList:(NSArray *)list {
    self = [super init] ;
    if (self) {
        self.backgroundColor = [UIColor whiteColor] ;
        if (!list) list = [self defaultConfigList] ;
        
        UIView *topLine = [UIView new] ;
        topLine.backgroundColor = UIColorHex(@"e6e6e6") ;
        [self addSubview:topLine] ;
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self) ;
            make.height.equalTo(@1) ;
        }] ;
        
        __block float lastLeft = kFlexOfButtons ;
        [list enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL * _Nonnull stop) {
            MDToolbar_Buttons_Types type = number.intValue ;
            UIButton *bt = [self buttonWithMDTBtype:type] ;
            bt.tag = kTagOfButton + type ;
            if (!bt) {
                lastLeft += (kFlexOfButtons) ;
                return ;
            }
            
            [self.scrollview addSubview:bt] ;
            [bt mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20)) ;
                make.centerY.equalTo(self.scrollview) ;
                make.left.equalTo(self.scrollview.mas_left).offset(lastLeft) ;
            }] ;
            lastLeft += (20 + kMarginOfButtons) ;
        }] ;
        
        self.scrollview.contentSize = CGSizeMake(lastLeft - kMarginOfButtons + kFlexOfButtons, 40) ;
    }
    return self;
}

- (void)renderWithModel:(MarkdownModel *)model {
    [self clear] ;
    
    NSArray *typeTbList = @[] ;
    switch (model.type) {
        case MarkdownSyntaxHeaders: typeTbList = @[@(MDB_H)] ; break;
        case MarkdownInlineBold: typeTbList = @[@(MDB_B)] ; break;
        case MarkdownInlineItalic: typeTbList = @[@(MDB_I)] ; break;
        case MarkdownInlineDeletions: typeTbList = @[@(MDB_D)] ; break;
        case MarkdownInlineInlineCode: typeTbList = @[@(MDB_InlineCode)] ; break;
        case MarkdownInlineBoldItalic: typeTbList = @[@(MDB_B),@(MDB_I)] ; break ;
        case MarkdownSyntaxULLists: typeTbList = @[@(MDB_UL)] ; break;
        case MarkdownSyntaxOLLists: typeTbList = @[@(MDB_OL)] ; break;
        case MarkdownSyntaxTaskLists: typeTbList = @[@(MDB_TL)] ; break;
        case MarkdownSyntaxCodeBlock: typeTbList = @[@(MDB_Code)] ; break;
        case MarkdownSyntaxBlockquotes: typeTbList = @[@(MDB_Quote)] ; break;
        default: break;
    }
    
    for (NSNumber *number in typeTbList) {
        int type = number.intValue ;
        for (UIView *sub in self.scrollview.subviews) {
            if ([sub isKindOfClass:[UIButton class]]
                && sub.tag == kTagOfButton + type ) {
                UIButton *bt = (UIButton *)sub ;
                [bt setImage:[bt.currentImage imageWithTintColor:XT_MD_THEME_COLOR_KEY(k_md_themeColor)] forState:0] ;
            }
        }
    }
}

- (void)clear {
    for (UIView *sub in self.scrollview.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *bt = (UIButton *)sub ;
            [bt setImage:[self imageFortype:bt.tag - kTagOfButton] forState:0] ;
        }
    }
}

- (NSArray *)defaultConfigList {
    return @[@(MDB_H),@(MDB_Sepline),@(MDB_flex),
             @(MDB_B),@(MDB_I),@(MDB_D),@(MDB_InlineCode),@(MDB_flex),
             @(MDB_Photo),@(MDB_Link),@(MDB_flex),
             @(MDB_UL),@(MDB_OL),@(MDB_TL),@(MDB_flex),
             @(MDB_Code),@(MDB_Quote),@(MDB_flex),
             @(MDB_Undo),@(MDB_Redo),
             ] ;
}

- (NSArray *)headerList {
    return @[@(MDB_H1),@(MDB_H2),@(MDB_H3),@(MDB_H4),@(MDB_H5),@(MDB_H6)] ;
}

- (UIButton *)buttonWithMDTBtype:(MDToolbar_Buttons_Types)type {
    UIImage *img = [self imageFortype:type] ;
    if (!img) return nil ;
    
    UIButton *button = [UIButton new] ;
    button.touchExtendInset = UIEdgeInsetsMake(-5, -5, -5, -5) ;
    WEAK_SELF
    [button bk_addEventHandler:^(id sender) {
        [weakSelf buttonOnClick:sender type:type] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    [button setImage:img forState:0] ;
    return button ;
}

- (void)buttonOnClick:(UIButton *)button type:(MDToolbar_Buttons_Types)type {
    switch (type) {
        case MDB_H: [self buttonH_onClicked] ; break ;
//        case MDB_H1: [self.mdt_delegate toolbarDidSelectH1] ; break ;
//        case MDB_H2: [self.mdt_delegate toolbarDidSelectH2] ; break ;
//        case MDB_H3: [self.mdt_delegate toolbarDidSelectH3] ; break ;
//        case MDB_H4: [self.mdt_delegate toolbarDidSelectH4] ; break ;
//        case MDB_H5: [self.mdt_delegate toolbarDidSelectH5] ; break ;
//        case MDB_H6: [self.mdt_delegate toolbarDidSelectH6] ; break ;
        case MDB_Sepline: [self.mdt_delegate toolbarDidSelectSepLine] ; break ;
            
        case MDB_B: [self.mdt_delegate toolbarDidSelectBold] ; break ;
        case MDB_I: [self.mdt_delegate toolbarDidSelectItalic] ; break ;
        case MDB_D: [self.mdt_delegate toolbarDidSelectDeletion] ; break ;
        case MDB_InlineCode: [self.mdt_delegate toolbarDidSelectInlineCode] ; break ;
            
        case MDB_Photo: [self.mdt_delegate toolbarDidSelectPhoto] ; break ;
        case MDB_Link: [self.mdt_delegate toolbarDidSelectLink] ; break ;
            
        case MDB_UL: [self.mdt_delegate toolbarDidSelectUList] ; break ;
        case MDB_OL: [self.mdt_delegate toolbarDidSelectOrderlist] ; break ;
        case MDB_TL: [self.mdt_delegate toolbarDidSelectTaskList] ; break ;
            
        case MDB_Code: [self.mdt_delegate toolbarDidSelectCodeBlock] ; break ;
        case MDB_Quote: [self.mdt_delegate toolbarDidSelectQuoteBlock] ; break ;
            
        case MDB_Undo: [self.mdt_delegate toolbarDidSelectUndo] ; break ;
        case MDB_Redo: [self.mdt_delegate toolbarDidSelectRedo] ; break ;
            
        default:
            break;
    }
}

- (UIImage *)imageFortype:(MDToolbar_Buttons_Types)type {
    NSString *imgStr = nil ;
    switch (type) {
        case MDB_H: imgStr = @"md_tb_bt_h" ; break ;
        case MDB_H1: imgStr = @"md_tb_bt_h1" ; break ;
        case MDB_H2: imgStr = @"md_tb_bt_h2" ; break ;
        case MDB_H3: imgStr = @"md_tb_bt_h3" ; break ;
        case MDB_H4: imgStr = @"md_tb_bt_h4" ; break ;
        case MDB_H5: imgStr = @"md_tb_bt_h5" ; break ;
        case MDB_H6: imgStr = @"md_tb_bt_h6" ; break ;
        case MDB_Sepline: imgStr = @"md_tb_bt_sepline" ; break ;
            
        case MDB_B: imgStr = @"md_tb_bt_bold" ; break ;
        case MDB_I: imgStr = @"md_tb_bt_italic" ; break ;
        case MDB_D: imgStr = @"md_tb_bt_deletion" ; break ;
        case MDB_InlineCode: imgStr = @"md_tb_bt_code" ; break ;
            
        case MDB_Photo: imgStr = @"md_tb_bt_photo" ; break ;
        case MDB_Link: imgStr = @"md_tb_bt_link" ; break ;
            
        case MDB_UL: imgStr = @"md_tb_bt_ulist" ; break ;
        case MDB_OL: imgStr = @"md_tb_bt_olist" ; break ;
        case MDB_TL: imgStr = @"md_tb_bt_tasklist" ; break ;
            
        case MDB_Code: imgStr = @"md_tb_bt_blkCode" ; break ;
        case MDB_Quote: imgStr = @"md_tb_bt_quote" ; break ;
            
        case MDB_Undo: imgStr = @"md_tb_bt_undo" ; break ;
        case MDB_Redo: imgStr = @"md_tb_bt_redo" ; break ;

        default:
            break;
    }
    
    return [UIImage imageNamed:imgStr] ;
}

- (void)buttonH_onClicked {
    XTSIAlertView *alert = [[XTSIAlertView alloc] initWithTitle:nil andMessage:nil] ;
    WEAK_SELF
    [alert addButtonWithTitle:@"H1" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectH1] ;
    }] ;
    [alert addButtonWithTitle:@"H2" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectH2] ;
    }] ;
    [alert addButtonWithTitle:@"H3" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectH3] ;
    }] ;
    [alert addButtonWithTitle:@"H4" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectH4] ;
    }] ;
    [alert addButtonWithTitle:@"H5" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectH5] ;
    }] ;
    [alert addButtonWithTitle:@"H6" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectH6] ;
    }] ;
    [alert addButtonWithTitle:@"非标题" type:XTSIAlertViewButtonTypeDefault handler:^(XTSIAlertView *alertView) {
        [weakSelf.mdt_delegate toolbarDidSelectRemoveTitle] ;
    }] ;
    [alert addButtonWithTitle:@"取消" type:XTSIAlertViewButtonTypeCancel handler:^(XTSIAlertView *alertView) {
    }] ;
    
    [alert show] ;
}

- (UIScrollView *)scrollview{
    if(!_scrollview){
        _scrollview = ({
            UIScrollView * object = [[UIScrollView alloc]init];
            [self addSubview:object] ;
            [object mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(1) ;
                make.left.right.bottom.equalTo(self) ;
            }] ;
            
            object;
       });
    }
    return _scrollview;
}

@end
