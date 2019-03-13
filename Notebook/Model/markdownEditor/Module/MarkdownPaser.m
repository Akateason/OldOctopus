//
//  MarkdownPaser.m
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownPaser.h"
#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"
#import "model/MDHeadModel.h"
#import "model/MdInlineModel.h"
#import "model/MdListModel.h"
#import "model/MdBlockModel.h"
#import "model/MdOtherModel.h"


@interface MarkdownPaser ()
@property (strong, nonatomic) MDThemeConfiguration *configuration;
@property (copy, nonatomic) NSArray *currentPaserResultList ;
@end

@implementation MarkdownPaser

- (instancetype)initWithConfig:(MDThemeConfiguration *)config {
    self = [super init];
    if (self) {
        _configuration = config ;
        _currentPaserResultList = @[] ;
    }
    return self;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type {
    switch (type) {
        case MarkdownSyntaxUnknown:
            return nil;
            
        case MarkdownSyntaxHeaders:
            return regexp(MDPR_heading, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxLHeader:
            return regexp(MDPR_lheading, NSRegularExpressionAnchorsMatchLines) ;
            
        case MarkdownSyntaxBold:
            return regexp("(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)", 0);
        case MarkdownSyntaxItalic:
            return regexp("((?<!\\*)\\*(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*(?!\\*)|(?<!_)_(?=[^ \\t_])(.+?)(?<=[^ \\t_])_(?!_))", 0);
        case MarkdownSyntaxBoldItalic:
            return regexp("((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))", 0);
        case MarkdownSyntaxDeletions:
            return regexp("\\~\\~(.*?)\\~\\~", 0);
        case MarkdownSyntaxInlineCode:
            return regexp("`(.*?)`", 0);
        case MarkdownSyntaxLinks:
            return regexp("\\[([^\\[]+)\\]\\(([^\\)]+)\\)", 0);
            
        case MarkdownSyntaxTaskLists:
            return regexp(MDPR_tasklist, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxOLLists:
            return regexp(MDPR_orderlist, NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxULLists:
            return regexp(MDPR_bulletlist, NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxTaskList_Checkbox:
            return regexp(MDPR_checkbox, NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxULLists_Bullet:
            return regexp(MDPR_bullet, NSRegularExpressionAnchorsMatchLines);
            
        case MarkdownSyntaxBlockquotes:
            return regexp(MDPR_blockquote,NSRegularExpressionAnchorsMatchLines); // "(&gt;|\\>)(.*)"
        case MarkdownSyntaxCodeBlock:
            return regexp("```([\\s\\S]*?)```[\\s]?",NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHr:
            return regexp(MDPR_hr, NSRegularExpressionAnchorsMatchLines) ;
            
        case MarkdownSyntaxNewLine:
            return regexp(MDPR_newline, NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxCode:
            return regexp(MDPR_code, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxDef:
            return regexp(MDPR_def, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxParagraph:
            return regexp(MDPR_paragraph, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxText:
            return regexp(MDPR_text, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxFrontMatter:
            return regexp(MDPR_frontmatter, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxMultipleMath:
            return regexp(MDPR_multiplemath, NSRegularExpressionAnchorsMatchLines) ;
            
        case NumberOfMarkdownSyntax: break ;
    }
    return nil;
}

- (NSArray *)syntaxModelsForText:(NSString *)text {
    NSMutableArray *markdownSyntaxModels = [@[] mutableCopy] ;
    
    for (MarkdownSyntaxType i = MarkdownSyntaxUnknown; i < NumberOfMarkdownSyntax; i++) {
        NSRegularExpression *expression = [self getRegularExpressionFromMarkdownSyntaxType:i] ;
        NSArray *matches = [expression matchesInString:text options:0 range:NSMakeRange(0, [text length])] ;
        for (NSTextCheckingResult *result in matches) {
            id model = nil ;
            switch (i) {
                case MarkdownSyntaxHeaders:
                case MarkdownSyntaxLHeader: {
                    model = [MDHeadModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
                }
                    break;
                    
                case MarkdownSyntaxBold:
                case MarkdownSyntaxItalic:
                case MarkdownSyntaxBoldItalic:
                case MarkdownSyntaxDeletions:
                case MarkdownSyntaxInlineCode:
                case MarkdownSyntaxLinks: {
                    model = [MdInlineModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
                }
                    break;
                    
                case MarkdownSyntaxTaskLists:
                case MarkdownSyntaxOLLists:
                case MarkdownSyntaxULLists:
                case MarkdownSyntaxTaskList_Checkbox:
                case MarkdownSyntaxULLists_Bullet: {
                    model = [MdListModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
                }
                    break;
                    
                case MarkdownSyntaxBlockquotes:
                case MarkdownSyntaxCodeBlock:
                case MarkdownSyntaxHr: {
                    model = [MdBlockModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
                }
                    break;
                    
                case MarkdownSyntaxNewLine:
                case MarkdownSyntaxCode:
                case MarkdownSyntaxDef:
                case MarkdownSyntaxParagraph:
                case MarkdownSyntaxText:
                case MarkdownSyntaxFrontMatter:
                case MarkdownSyntaxMultipleMath: {
                    model = [MdOtherModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
                }
                    break;
                    
                default: {
                    model = [MarkdownModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
                }
                    break;
            }
            
            [markdownSyntaxModels addObject:model] ;
        }
    }
    self.currentPaserResultList = markdownSyntaxModels ;
    return markdownSyntaxModels;
}

- (MarkdownModel *)modelForRangePosition:(NSUInteger)position {
    NSArray *list = self.currentPaserResultList ;
    for (int i = 0; i < list.count; i++) {
        MarkdownModel *model = list[i] ;
        BOOL isInRange = NSLocationInRange(position, model.range) ;
                
        if (isInRange) {
            return model ;
        }
    }
    return nil ;
}

+ (NSString *)stringTitleOfModel:(MarkdownModel *)model {
    return [model displayStringForLeftLabel] ;
}

- (NSAttributedString *)parseText:(NSString *)text {
    NSArray *models = [self syntaxModelsForText:text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString beginEditing] ;
    [attributedString addAttributes:self.configuration.basicStyle range:NSMakeRange(0, text.length)] ;
    
    for (MarkdownModel *model in models) {
        attributedString = [self makeAttributeString:attributedString model:model] ;
    }
    [attributedString endEditing] ;
    
    return attributedString ;
}

- (NSMutableAttributedString *)makeAttributeString:(NSMutableAttributedString *)attributedString model:(MarkdownModel *)model {
    return [model addForAttributeString:attributedString config:self.configuration] ;
}


@end
