//
//  MDCodeBlockEditor.m
//  Notebook
//
//  Created by teason23 on 2019/4/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDCodeBlockEditor.h"
#import "MDThemeConfiguration.h"
#import "RegexHighlightView.h"
#import <XTlib/XTlib.h>
#import <BlocksKit+UIKit.h>

@interface MDCodeBlockEditor () <RegexHighlightViewDelegate>
@property (strong, nonatomic) RegexHighlightView *highlightView ;
@property (strong, nonatomic) UIButton *btCodeType ;
@property (strong, nonatomic) MdBlockModel *model ;
@property (copy, nonatomic) NSString *oldCodeStr ;
@end

@implementation MDCodeBlockEditor

- (instancetype)initWithFrame:(CGRect)frame
                        model:(MdBlockModel *)model {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = XT_MD_THEME_COLOR_KEY(k_md_bgColor) ;
        
        
        self.model = model ;
        
        NSString *firstPrefix = [[model.str componentsSeparatedByString:@"\n"] firstObject] ;
        NSRange range = NSMakeRange(firstPrefix.length + 1, model.length - 4 - firstPrefix.length - 1) ;
        NSString *textStr = [model.str substringWithRange:range] ;
        
        NSString *themeKey = [[MDThemeConfiguration sharedInstance] currentThemeKey] ;
        RegexHighlightViewTheme theme = [themeKey isEqualToString:@"themeDefault"] ? kRegexHighlightViewThemeDefault : kRegexHighlightViewThemeMidnight ;
        
        NSString *codeStr = [[model.str componentsSeparatedByString:@"\n"] firstObject] ;
        codeStr = [codeStr substringFromIndex:3] ;
        self.oldCodeStr = codeStr ;
        codeStr = codeStr.length ? codeStr : @"点击选择代码块语言" ;
        [self.btCodeType setTitle:XT_STR_FORMAT(@"%@",codeStr) forState:0] ;
        
        RegexHighlightView *highlightView =
        [[RegexHighlightView alloc] initWithText:textStr
                                           theme:theme
                                            path:[[NSBundle mainBundle] pathForResource:codeStr ofType:@"plist"]] ;
        highlightView.scrollEnabled = NO ;
        highlightView.userInteractionEnabled = NO ;
        [self addSubview:highlightView] ;
        [highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self) ;
            make.top.equalTo(self.mas_top).offset(25) ;
            make.left.equalTo(self.mas_left).offset(15) ;
            make.right.equalTo(self.mas_right).offset(-15) ;
        }] ;
        highlightView.regexDelegate = self ;
        highlightView.backgroundColor = nil ;
        self.highlightView = highlightView ;
        
        UIView *bgView = [UIView new] ;
        bgView.backgroundColor = XT_MD_THEME_COLOR_KEY_A(k_md_textColor, 0.03) ;
        bgView.xt_borderColor = XT_MD_THEME_COLOR_KEY_A(k_md_textColor, 0.1) ;
        bgView.xt_borderWidth = .5 ;
        bgView.xt_cornerRadius = 4. ;
        [self addSubview:bgView] ;
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self) ;
            make.top.equalTo(highlightView.mas_top).offset(5) ;
//            make.top.equalTo(highlightView.mas_top).offset(0) ;
//            make.bottom.equalTo(highlightView.mas_bottom).offset(0) ;
            make.bottom.equalTo(highlightView.mas_bottom).offset(-15) ;
        }] ;
        
    }
    return self ;
}

#define kLangugeArray   @[@"java",@"c",@"python",@"cpp",@"javascript",@"csharp",@"php",@"sql",@"objectivec",@"vb",@"ruby"]

- (UIButton *)btCodeType {
    if (!_btCodeType) {
        _btCodeType = [UIButton new] ;
        [_btCodeType setTitleColor:XT_MD_THEME_COLOR_KEY_A(k_md_linkColor,1) forState:0] ;
        _btCodeType.titleLabel.font = [UIFont systemFontOfSize:kDefaultFontSize] ;
        [self addSubview:_btCodeType] ;
        [_btCodeType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self) ;
            make.height.equalTo(@30) ;
        }] ;
        
        [_btCodeType bk_addEventHandler:^(id sender) {
            WEAK_SELF
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:@"代码块语言格式" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:kLangugeArray fromWithView:sender CallBackBlock:^(NSInteger btnIndex) {
                if (btnIndex) {
                    NSString *code = kLangugeArray[btnIndex - 1] ;
                    if (weakSelf.delegate) {
                        [weakSelf.delegate changeCodeFormatWithLocation:weakSelf.model.location newCodeString:code oldCode:weakSelf.oldCodeStr] ;
                    }
                }
                
            }] ;
            
        } forControlEvents:(UIControlEventTouchUpInside)] ;
    }
    return _btCodeType ;
}

//#pragma mark - RegexHighlightViewDelegate <NSObject>
//- (void)textChanged:(NSString *)text {
//
//}


@end
