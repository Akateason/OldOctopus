//
//  WebModel.m
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "WebModel.h"
#import "MdParserRegexpHeader.h"
#import <XTlib/XTlib.h>

@implementation WebModel

+ (NSArray *)currentTypeWithList:(NSString *)jsonlist  {
    NSArray *list = [NSArray yy_modelWithJSON:jsonlist] ;
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    for (NSString *str in list) {
        int val = [self getTypeFromStr:str] ;
        [tmplist addObject:@(val)] ;
    }
    
    return tmplist ;
}

+ (int)getTypeFromStr:(NSString *)resultStr {
    if ([resultStr isEqualToString:@"h1"]) {
        return MarkdownSyntaxH1 ;
    }
    else if ([resultStr isEqualToString:@"h2"]) {
        return MarkdownSyntaxH2 ;
    }
    else if ([resultStr isEqualToString:@"h3"]) {
        return MarkdownSyntaxH3 ;
    }
    else if ([resultStr isEqualToString:@"h4"]) {
        return MarkdownSyntaxH4 ;
    }
    else if ([resultStr isEqualToString:@"h5"]) {
        return MarkdownSyntaxH5 ;
    }
    else if ([resultStr isEqualToString:@"h6"]) {
        return MarkdownSyntaxH6 ;
    }
    else if ([resultStr isEqualToString:@"figure"]) {
        return MarkdownSyntaxTable ;
    }
    else if ([resultStr isEqualToString:@"pre"]) {
        return MarkdownSyntaxCodeBlock ;
    }
    else if ([resultStr isEqualToString:@"blockquote"]) {
        return MarkdownSyntaxBlockquotes ;
    }
    else if ([resultStr isEqualToString:@"ol"]) {
        return MarkdownSyntaxOLLists ;
    }
    else if ([resultStr isEqualToString:@"ul"]) {
        return MarkdownSyntaxULLists ;
    }
    else if ([resultStr isEqualToString:@"p"]) {
        return MarkdownSyntaxUnknown ;
    }
    else if ([resultStr isEqualToString:@"hr"]) {
        return MarkdownSyntaxHr ;
    }
    else if ([resultStr isEqualToString:@"strong"]) {
        return MarkdownInlineBold ;
    }
    else if ([resultStr isEqualToString:@"em"]) {
        return MarkdownInlineItalic ;
    }
    else if ([resultStr isEqualToString:@"inline_code"]) {
        return MarkdownInlineInlineCode ;
    }
    else if ([resultStr isEqualToString:@"del"]) {
        return MarkdownInlineDeletions ;
    }
    else if ([resultStr isEqualToString:@"link"]) {
        return MarkdownInlineLinks ;
    }
    else if ([resultStr isEqualToString:@"image"]) {
        return MarkdownInlineImage ;
    }
    else if ([resultStr isEqualToString:@"inline_math"]) {
        return MarkdownSyntaxMultipleMath ;
    }
    
    return MarkdownSyntaxUnknown ;
}

@end


@implementation WordCount

@end
