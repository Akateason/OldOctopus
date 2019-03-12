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
#import <XTlib/XTlib.h>

#define regexp(reg,option) [NSRegularExpression regularExpressionWithPattern:@reg options:option error:NULL]

@implementation MarkdownPaser

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentPaserResultList = @[] ;
    }
    return self;
}

- (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:16] ;
}

- (NSDictionary *)defaultStyle {
    NSDictionary *resultDic = @{
                                NSFontAttributeName : [self defaultFont],
//                                NSParagraphStyleAttributeName : pParagraphStyle,
                                };
    return resultDic ;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)v {
    switch (v) {
        case MarkdownSyntaxUnknown:
            return nil;
        case MarkdownSyntaxHeaders:
            return regexp("^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
            
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
            return regexp("^( *)([*+-]) [\\s\\S]+?(?:hr|def|\\n{2,}(?! )(?!\\1[*+-] )\\n*|\\s*$)", NSRegularExpressionAnchorsMatchLines); // ^( *)([*+-]) [\s\S]+?(?:hr|def|\n{2,}(?! )(?!\1[*+-] )\n*|\s*$)   // ^\\*([^\\*]*)
        case MarkdownSyntaxOLLists:
            return regexp("^[0-9]+\\.(.*)", NSRegularExpressionAnchorsMatchLines);
        case NumberOfMarkdownSyntax:
            break;
    }
    return nil;
}

- (NSDictionary *)attributesFromMarkdownSyntaxModel:(MarkdownModel *)model {
    MarkdownSyntaxType v = model.type ;
    NSDictionary *resultDic = [self defaultStyle] ;
    UIFont *paragraphFont = [self defaultFont] ;
    
    switch (v) {
        case MarkdownSyntaxUnknown:
            break ;
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[model.str componentsSeparatedByString:@" "] firstObject] ;
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
        }
            break ;
        
        case MarkdownSyntaxLinks:
            resultDic = @{NSForegroundColorAttributeName : [UIColor blueColor],
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxBold:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
            break ;
        case MarkdownSyntaxEmphasis:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
            break ;
        case MarkdownSyntaxDeletions:
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxQuotes:
            resultDic = @{NSForegroundColorAttributeName : [UIColor lightGrayColor],
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxInlineCode:
            resultDic = @{NSForegroundColorAttributeName : [UIColor brownColor],
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxCodeBlock:
            resultDic = @{
                          NSBackgroundColorAttributeName : [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0],
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxBlockquotes:
            resultDic = @{NSBackgroundColorAttributeName : [UIColor lightGrayColor],
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxULLists: {
            NSMutableParagraphStyle* listParagraphStyle = [[NSMutableParagraphStyle alloc]init];
            listParagraphStyle.headIndent = 16.0;
            resultDic = @{NSFontAttributeName : paragraphFont,
                          NSParagraphStyleAttributeName : listParagraphStyle,
                          NSForegroundColorAttributeName : [UIColor redColor]
                          } ;
        }
            break ;
        case MarkdownSyntaxOLLists: {
            NSMutableParagraphStyle* listItemParagraphStyle = [[NSMutableParagraphStyle alloc]init];
            listItemParagraphStyle.headIndent = 16.0;
            resultDic = @{NSFontAttributeName : paragraphFont,
                          NSParagraphStyleAttributeName : listItemParagraphStyle,
                          NSForegroundColorAttributeName : [UIColor greenColor]
                          };
        }
            break ;
            
        case NumberOfMarkdownSyntax: break;
    }
    return resultDic;
}


- (NSArray *)syntaxModelsForText:(NSString *)text {
    NSMutableArray *markdownSyntaxModels = [@[] mutableCopy] ;
    
    for (MarkdownSyntaxType i = MarkdownSyntaxUnknown; i < NumberOfMarkdownSyntax; i++) {
        NSRegularExpression *expression = [self getRegularExpressionFromMarkdownSyntaxType:i] ;
        NSArray *matches = [expression matchesInString:text options:0 range:NSMakeRange(0, [text length])] ;
        for (NSTextCheckingResult *result in matches) {
            MarkdownModel *model = [MarkdownModel modelWithType:i range:result.range str:[text substringWithRange:result.range]] ;
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
    NSString *str = @"" ;
    
    switch (model.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[model.str componentsSeparatedByString:@" "] firstObject] ;
            NSUInteger numberOfmark = prefix.length ;
            str = STR_FORMAT(@"H%lu",(unsigned long)numberOfmark) ;
        }  break ;
        case MarkdownSyntaxLinks: str = @"link" ; break ;
        case MarkdownSyntaxBold: str = @"B" ; break ;
        case MarkdownSyntaxEmphasis: str = @"B" ; break ;
        case MarkdownSyntaxDeletions: str = @"D" ; break ;
        case MarkdownSyntaxQuotes: str = @"q" ; break ;
        case MarkdownSyntaxInlineCode: str = @"inline code" ; break ;
        case MarkdownSyntaxCodeBlock: str = @"code block" ; break ;
        case MarkdownSyntaxBlockquotes: str = @"block quotes" ; break ;
        
        case MarkdownSyntaxULLists: str = @"ul" ; break ;
        case MarkdownSyntaxOLLists: str = @"ol" ; break ;
        
        
        default: break;
    }
    return str ;
}

@end
