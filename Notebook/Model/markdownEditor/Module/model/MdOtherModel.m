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
//        case MarkdownSyntaxParagraph : {
//            resultDic = @{NSBackgroundColorAttributeName : [[XTColorFetcher sharedInstance] randomColor],} ;
//            [attributedString addAttributes:resultDic range:self.range] ;
//        }
            break ;
        default: break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    return attributedString ;
}

@end
