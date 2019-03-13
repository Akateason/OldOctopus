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
#import <XTBase/XTBase.h>


@implementation MarkdownModel

- (instancetype)initWithType:(MarkdownSyntaxType)type
                       range:(NSRange)range
                         str:(NSString *)str {
    self = [super init];
    if (self) {
        _type = type;
        _range = range;
        _str = str ;
    }
    return self;
}

+ (instancetype)modelWithType:(MarkdownSyntaxType)type
                        range:(NSRange)range
                          str:(NSString *)str {
    return [[self alloc] initWithType:type range:range str:str] ;
}

@end






static int kDefaultFontSize = 16 ;

@interface MarkdownPaser ()

@end

@implementation MarkdownPaser

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentPaserResultList = @[] ;
    }
    return self;
}

- (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:kDefaultFontSize] ;
}

- (UIFont *)boldFont {
    NSDictionary *fontDict = @{UIFontDescriptorFaceAttribute: @"Bold"} ;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
    return [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
}

- (UIFont *)itatlicFont {
    NSDictionary *fontDict = @{UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)]} ;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
    return [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
}

- (UIFont *)boldItalicFont {
    NSDictionary *fontDict = @{
                               UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)],
                               UIFontDescriptorFaceAttribute: @"Bold"
                               } ;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
    return [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
}

- (NSDictionary *)defaultStyle {
    return @{NSFontAttributeName : [self defaultFont]};
}

- (NSDictionary *)defaultMarkStyle {
    return @{NSForegroundColorAttributeName : UIColorHex(@"909399")} ;
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type {
    switch (type) {
        case MarkdownSyntaxUnknown:
            return nil;
            
        case MarkdownSyntaxNewLine:
            return regexp(MDPR_newline, NSRegularExpressionAnchorsMatchLines);
            
        case MarkdownSyntaxCode:
            return regexp(MDPR_code, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxHr:
            return regexp(MDPR_hr, NSRegularExpressionAnchorsMatchLines) ;
        case MarkdownSyntaxDef:
            return regexp(MDPR_def, NSRegularExpressionAnchorsMatchLines) ;
            
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
        case MarkdownSyntaxCode: str = @"缩进"; break ;
        case MarkdownSyntaxHr: str = @"分割线"; break ;
            
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[model.str componentsSeparatedByString:@" "] firstObject] ;
            NSUInteger numberOfmark = [NSString rangesOfString:prefix referString:@"#"].count ;
            str = STR_FORMAT(@"H%lu",(unsigned long)numberOfmark) ;
            if (![model.str containsString:@" "] || numberOfmark > 6) str = @"" ;
            
        }  break ;
        case MarkdownSyntaxLHeader: str = @"H1"; break ;
            
        case MarkdownSyntaxBold: str = @"B" ; break ;
        case MarkdownSyntaxItalic: str = @"I" ; break ;
        case MarkdownSyntaxBoldItalic: str = @"BI" ; break ;
        case MarkdownSyntaxDeletions: str = @"D" ; break ;
        case MarkdownSyntaxInlineCode: str = @"行内代码" ; break ;
        case MarkdownSyntaxLinks: str = @"链接" ; break ;
        
        case MarkdownSyntaxTaskLists: str = @"tl" ; break ;
        case MarkdownSyntaxULLists: str = @"ul" ; break ;
        case MarkdownSyntaxOLLists: str = @"ol" ; break ;
            
        case MarkdownSyntaxBlockquotes: str = @"引用" ; break ;
        case MarkdownSyntaxCodeBlock: str = @"代码块" ; break ;
        
        default: break ;
    }
    return str ;
}

- (NSAttributedString *)parseText:(NSString *)text {
    NSArray *models = [self syntaxModelsForText:text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString beginEditing] ;
    [attributedString addAttributes:self.defaultStyle range:NSMakeRange(0, text.length)] ;
    
    for (MarkdownModel *model in models) {
        attributedString = [self makeAttributeString:attributedString model:model] ;
    }
    [attributedString endEditing] ;
    
    return attributedString ;
}

- (NSMutableAttributedString *)makeAttributeString:(NSMutableAttributedString *)attributedString
                                             model:(MarkdownModel *)model {
    
    MarkdownSyntaxType v = model.type ;
    NSDictionary *resultDic = [self defaultStyle] ;
    UIFont *paragraphFont = [self defaultFont] ;
    NSUInteger location = model.range.location ;
    NSUInteger length = model.range.length ;
    
    switch (v) {
        case MarkdownSyntaxUnknown: break ;
            
        case MarkdownSyntaxNewLine: break ;
            
        case MarkdownSyntaxCode: break ;
        case MarkdownSyntaxHr: { // 分割线 ___
            
        }
            break ;
        case MarkdownSyntaxDef: break ; // 未知
            
        // header
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
            [attributedString addAttributes:resultDic range:model.range] ;
            
            NSRange markRange = NSMakeRange(location, numberOfmark) ;
            [attributedString addAttributes:[self defaultMarkStyle] range:markRange] ;
        }
            break ;
        case MarkdownSyntaxLHeader: {
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:32]} ;
            [attributedString addAttributes:resultDic range:model.range] ;
            
            NSString *nail = [[model.str componentsSeparatedByString:@"\n"] lastObject] ;
            NSRange markRange = NSMakeRange(location + length - nail.length, nail.length) ;
            [attributedString addAttributes:[self defaultMarkStyle] range:markRange] ;
        }
            break ;
            
        // inline
        case MarkdownSyntaxBold: {
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSFontAttributeName : [self boldFont]} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownSyntaxItalic: {
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSFontAttributeName : [self itatlicFont]};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownSyntaxBoldItalic: {
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location + length - 3, 3)] ;
            
            resultDic = @{NSFontAttributeName : [self boldItalicFont]};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownSyntaxDeletions: {
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location + length - 2, 2)] ;

            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownSyntaxInlineCode: {
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location + length - 1, 1)] ;

            resultDic = @{NSBackgroundColorAttributeName : UIColorHex(@"f0f1f1"),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownSyntaxLinks: {
            resultDic = @{NSForegroundColorAttributeName : [UIColor blueColor],
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:model.range] ;
        }
            break ;
            
        // 列表
        case MarkdownSyntaxOLLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:model.range] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:model.range] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            resultDic = @{NSFontAttributeName : paragraphFont} ;
            [attributedString addAttributes:resultDic range:model.range] ;
        }
            break ;
        case MarkdownSyntaxTaskList_Checkbox: break ;
        case MarkdownSyntaxULLists_Bullet: break ;
            
        // block
        case MarkdownSyntaxBlockquotes: {
            // todo 引用 的 竖线
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.headIndent += 16;
            paragraphStyle.firstLineHeadIndent += 16;
            resultDic = @{NSForegroundColorAttributeName : UIColorHex(@"777777"),
                          NSFontAttributeName : paragraphFont,
                          NSParagraphStyleAttributeName :paragraphStyle
                          };
            [attributedString addAttributes:resultDic range:model.range] ;
        }
            break ;
        case MarkdownSyntaxCodeBlock: {
            resultDic = @{NSBackgroundColorAttributeName : UIColorHex(@"f0f1f1"),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:model.range] ;
            
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:[self defaultMarkStyle] range:NSMakeRange(location + length - 3, 3)] ;
        }
            break ;
            
        // other
        case MarkdownSyntaxParagraph: break ; // 段落
        case MarkdownSyntaxText: break ; // 文字
        case MarkdownSyntaxFrontMatter: break ; // 未知
        case MarkdownSyntaxMultipleMath: { // 数学
            resultDic = @{NSBackgroundColorAttributeName : [UIColor brownColor],} ;
            [attributedString addAttributes:resultDic range:model.range] ;
        }
            break ;
            
            
        // end
        case NumberOfMarkdownSyntax: break ;
    }
    
    return attributedString ;
}


@end
