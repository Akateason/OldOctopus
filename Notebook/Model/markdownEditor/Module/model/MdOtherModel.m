//
//  MdOtherModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdOtherModel.h"
#import <XTlib/XTlib.h>

@implementation MdOtherModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
//        case MarkdownSyntaxMultipleMath: str = @"数学"; break;
        case MarkdownSyntaxHr: str = @"md_tb_bt_sepline" ; break ;
//        case MarkdownSyntaxTable: str = @"表格1" ; break ;
//        case MarkdownSyntaxNpTable: str = @"表格2" ; break ;
        default: break;
    }
    return str ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxMultipleMath: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break;
        case MarkdownSyntaxHr: {
            UIFont *hrFont = [UIFont systemFontOfSize:4] ;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 0 ;
            paragraphStyle.paragraphSpacing = kDefaultFontSize * 1.3 ;
            resultDic = @{NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_seplineLineColor) ,
                          NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_seplineLineColor) ,
                          NSFontAttributeName : hrFont ,
                          NSParagraphStyleAttributeName : paragraphStyle
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxNpTable: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;
        case MarkdownSyntaxTable: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;


        default: break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;

    switch (self.type) {
        case MarkdownSyntaxMultipleMath: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break;
        case MarkdownSyntaxHr: {
            resultDic = @{NSBackgroundColorAttributeName : [UIColor clearColor] ,
                          NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_markColor) ,
                          NSFontAttributeName : configuration.editorThemeObj.font,
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break;
        case MarkdownSyntaxNpTable: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;
        case MarkdownSyntaxTable: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}

@end
