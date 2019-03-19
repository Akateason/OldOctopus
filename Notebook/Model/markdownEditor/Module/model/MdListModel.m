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
        case MarkdownSyntaxTaskLists:   str = @"tl" ; break ;
        case MarkdownSyntaxOLLists:     str = @"ol" ; break ;
        case MarkdownSyntaxULLists:     str = @"ul" ; break ;
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
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:kDefaultFontSize]} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // bullet
            resultDic = @{NSFontAttributeName : [UIFont systemFontOfSize:20]} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 2)] ;
        }
            break ;

        
        default:
            break;
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
        case MarkdownSyntaxOLLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:kDefaultFontSize],
                          NSForegroundColorAttributeName : configuration.markColor
                          } ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.listStyle range:self.range] ;
            // bullet
            resultDic = @{NSFontAttributeName : configuration.font ,
                          NSForegroundColorAttributeName : configuration.markColor
                          } ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 2)] ;
       }
            break ;

            
            
        default:
            break;
    }
    
    return attributedString ;
}


@end
