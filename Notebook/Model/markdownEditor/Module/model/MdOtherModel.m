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
        case MarkdownSyntaxMultipleMath: str = @"数学"; break;
        case MarkdownSyntaxHr: str = @"分割线" ; break ;
        case MarkdownSyntaxTable: str = @"表格1" ; break ;
        case MarkdownSyntaxNpTable: str = @"表格2" ; break ;
        default: break;
    }
    return str ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxMultipleMath: {
            resultDic = @{NSBackgroundColorAttributeName : [UIColor brownColor],} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break;
        case MarkdownSyntaxHr: {
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            paraStyle.paragraphSpacing = 16 ;
            UIFont *hrFont = [UIFont systemFontOfSize:4] ;
            resultDic = @{NSBackgroundColorAttributeName : UIColorHex(@"dcdcdc") ,
                          NSForegroundColorAttributeName : UIColorHex(@"dcdcdc") ,
                          NSFontAttributeName : hrFont ,
                          NSParagraphStyleAttributeName : paraStyle
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxNpTable: {
            resultDic = @{NSBackgroundColorAttributeName : [UIColor redColor],} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxTable: {
            resultDic = @{NSBackgroundColorAttributeName : [UIColor xt_skyBlue],} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;


        default: break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;

    switch (self.type) {
        case MarkdownSyntaxHr: {
            resultDic = @{NSBackgroundColorAttributeName : [UIColor clearColor] ,
                          NSForegroundColorAttributeName : configuration.markColor ,
                          NSFontAttributeName : configuration.font,
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break;
            
        default:
            break;
    }
    
    return attributedString ;
}

@end
