//
//  MDHeadModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDHeadModel.h"

@implementation MDHeadModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[self.str componentsSeparatedByString:@" "] firstObject] ;
            NSUInteger numberOfmark = [NSString rangesOfString:prefix referString:@"#"].count ;
            str = STR_FORMAT(@"H%lu",(unsigned long)numberOfmark) ;
            if (![self.str containsString:@" "] || numberOfmark > 6) str = @"" ;
        }
            break;
//        case MarkdownSyntaxLHeader: str = @"H1"; break ;
            
        default: break;
    }
    
    return str ;
}

- (NSMutableAttributedString *)addForAttributeString:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
//    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[self.str componentsSeparatedByString:@" "] firstObject] ;
            NSUInteger numberOfmark = prefix.length ;
            switch (numberOfmark) {
                case 1: resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:32]}; break;
                case 2: resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:24]}; break;
                case 3: resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20]}; break;
                case 4: resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}; break;
                case 5: resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]}; break;
                case 6: resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:12]}; break;
                default: break;
            }
            [attributedString addAttributes:resultDic range:self.range] ;
            
            NSRange markRange = NSMakeRange(location, numberOfmark) ;
            [attributedString addAttributes:configuration.markStyle range:markRange] ;
        }
            break;
//        case MarkdownSyntaxLHeader: {
//            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:32]} ;
//            [attributedString addAttributes:resultDic range:self.range] ;
//
//            NSString *nail = [[self.str componentsSeparatedByString:@"\n"] lastObject] ;
//            NSRange markRange = NSMakeRange(location + length - nail.length, nail.length) ;
//            [attributedString addAttributes:configuration.markStyle range:markRange] ;
//        }
            
        default:
            break;
    }
    
    return attributedString ;
}

@end
