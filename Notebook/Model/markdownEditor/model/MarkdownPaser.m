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
        case MarkdownSyntaxHeaders_h1:
            return regexp("^ *(#) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHeaders_h2:
            return regexp("^ *(##) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHeaders_h3:
            return regexp("^ *(###) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHeaders_h4:
            return regexp("^ *(####) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHeaders_h5:
            return regexp("^ *(#####) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHeaders_h6:
            return regexp("^ *(######) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines);
            
            
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

UIFont *defaultFont() {
    return [UIFont systemFontOfSize:16] ;
}

NSDictionary *Md_defaultStyle() {
//    NSMutableParagraphStyle* pParagraphStyle = [[NSMutableParagraphStyle alloc]init];
//    pParagraphStyle.paragraphSpacing = 12;
//    pParagraphStyle.paragraphSpacingBefore = 12;
    NSDictionary *resultDic = @{
                                NSFontAttributeName : defaultFont(),
//                                NSParagraphStyleAttributeName : pParagraphStyle,
                                };
    return resultDic ;
}

NSDictionary *AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v) {
    NSDictionary *resultDic = Md_defaultStyle() ;
    UIFont *paragraphFont = defaultFont() ;
    
    switch (v) {
        case MarkdownSyntaxUnknown:
            break ;
        case MarkdownSyntaxHeaders_h1:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:32]};
            break ;
        case MarkdownSyntaxHeaders_h2:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:24]};
            break ;
        case MarkdownSyntaxHeaders_h3:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20]};
            break ;
        case MarkdownSyntaxHeaders_h4:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
            break ;
        case MarkdownSyntaxHeaders_h5:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]};
            break ;
        case MarkdownSyntaxHeaders_h6:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:12]};
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
