//
//  XTMarkdownParser+Regular.m
//  Notebook
//
//  Created by teason23 on 2019/4/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTMarkdownParser+Regular.h"

@implementation XTMarkdownParser (Regular)


- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type {
    switch (type) {
        case MarkdownSyntaxUnknown: break;
            
        case MarkdownSyntaxHeaders:
            return regexp(MDPR_heading, NSRegularExpressionAnchorsMatchLines) ;
            
        case MarkdownSyntaxTaskLists:
            return regexp(MDPR_tasklist, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxOLLists:
            return regexp(MDPR_orderlist, NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxULLists:
            return regexp(MDPR_bulletlist, NSRegularExpressionAnchorsMatchLines);
            
        case MarkdownSyntaxBlockquotes:
            return regexp(MDPR_blockquote,NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxCodeBlock:
            return regexp(MDPR_codeBlock,NSRegularExpressionAnchorsMatchLines);
            
        case MarkdownSyntaxHr:
            return regexp(MDPR_hr, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxMultipleMath:
            return regexp(MDPR_multiplemath, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxNpTable:
            return regexp(MDPR_NpTable, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxTable :
            return regexp(MDPR_table, NSRegularExpressionAnchorsMatchLines) ;
            
        case NumberOfMarkdownSyntax: break ;
    }
    return nil;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownInlineType:(MarkdownInlineType)type {
    switch (type) {
        case MarkdownInlineUnknown: break ;
            
        case MarkdownInlineBold:
            return regexp(MDIL_BOLD, 0);
        case MarkdownInlineItalic:
            return regexp(MDIL_ITALIC, 0);
        case MarkdownInlineBoldItalic:
            return regexp(MDIL_BOLDITALIC, 0);
        case MarkdownInlineDeletions:
            return regexp(MDIL_DELETION, 0);
        case MarkdownInlineInlineCode:
            return regexp(MDIL_INLINECODE, 0);
        case MarkdownInlineLinks:
            return regexp(MDIL_LINKURL, 0);
        case MarkdownInlineImage:
            return regexp(MDIL_IMAGES, 0);
        case MarkdownInlineEscape:
            return regexp(MDIL_ESCAPE , 0);
            
        default: break;
    }
    return nil;
}

@end
