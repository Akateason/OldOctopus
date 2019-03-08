//
//  MarkdownPaser.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownPaser.h"
#import "MarkdownModel.h"
#import <UIKit/UIKit.h>

#define regexp(reg,option) [NSRegularExpression regularExpressionWithPattern:@reg options:option error:NULL]

NSRegularExpression *NSRegularExpressionFromMarkdownSyntaxType(MarkdownSyntaxType v) {
    switch (v) {
        case MarkdownSyntaxUnknown:
            return nil;
        case MarkdownSyntaxHeaders:
            return regexp("(#+)(.*)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxLinks:
            return regexp("\\[([^\\[]+)\\]\\(([^\\)]+)\\)", 0);
        case MarkdownSyntaxBold:
            return regexp("(\\*\\*|__)(.*?)\\1", 0);
        case MarkdownSyntaxEmphasis:
            return regexp("\\s(\\*|_)(.*?)\\1\\s", 0);
        case MarkdownSyntaxDeletions:
            return regexp("\\~\\~(.*?)\\~\\~", 0);
        case MarkdownSyntaxQuotes:
            return regexp("\\:\\\"(.*?)\\\"\\:", 0);
        case MarkdownSyntaxInlineCode:
            return regexp("`(.*?)`", 0);
        case MarkdownSyntaxCodeBlock:
            return regexp("```([\\s\\S]*?)```", 0);
        case MarkdownSyntaxBlockquotes:
            return regexp("\n(&gt;|\\>)(.*)",0);
        case MarkdownSyntaxULLists:
            return regexp("^\\*([^\\*]*)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxOLLists:
            return regexp("^[0-9]+\\.(.*)", NSRegularExpressionAnchorsMatchLines);
        case NumberOfMarkdownSyntax:
            break;
    }
    return nil;
}

NSDictionary *AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v) {
    switch (v) {
        case MarkdownSyntaxUnknown:
            return @{};
        case MarkdownSyntaxHeaders:
            return @{
                     NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                     };
        case MarkdownSyntaxLinks:
            return @{NSForegroundColorAttributeName : [UIColor blueColor]};
        case MarkdownSyntaxBold:
            return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]};
        case MarkdownSyntaxEmphasis:
            return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]};
        case MarkdownSyntaxDeletions:
            return @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)};
        case MarkdownSyntaxQuotes:
            return @{NSForegroundColorAttributeName : [UIColor lightGrayColor]};
        case MarkdownSyntaxInlineCode:
            return @{NSForegroundColorAttributeName : [UIColor brownColor]};
        case MarkdownSyntaxCodeBlock:
            return @{
                     NSBackgroundColorAttributeName : [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]
                     };
        case MarkdownSyntaxBlockquotes:
            return @{NSBackgroundColorAttributeName : [UIColor lightGrayColor]};
        case MarkdownSyntaxULLists:
            return @{};
        case MarkdownSyntaxOLLists:
            return @{};
        case NumberOfMarkdownSyntax:
            break;
    }
    return nil;
}



@implementation MarkdownPaser

- (NSArray *)syntaxModelsForText:(NSString *) text {
    NSMutableArray *markdownSyntaxModels = [NSMutableArray array];
    for (MarkdownSyntaxType i = MarkdownSyntaxUnknown; i < NumberOfMarkdownSyntax; i++) {
        NSRegularExpression *expression = NSRegularExpressionFromMarkdownSyntaxType(i);
        NSArray *matches = [expression matchesInString:text
                                               options:0
                                                 range:NSMakeRange(0, [text length])];
        for (NSTextCheckingResult *result in matches) {
            [markdownSyntaxModels addObject:[MarkdownModel modelWithType:i range:result.range]];
        }
    }
    return markdownSyntaxModels;
}

@end
