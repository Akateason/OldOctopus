//
//  MdListModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdListModel.h"

@implementation MdListModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxTaskLists: str = @"tl" ; break ;
        case MarkdownSyntaxULLists: str = @"ul" ; break ;
        case MarkdownSyntaxOLLists: str = @"ol" ; break ;
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
        case MarkdownSyntaxOLLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxTaskList_Checkbox: break ;
        case MarkdownSyntaxULLists_Bullet: break ;

            
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    return attributedString ;
}


@end
