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

- (NSRange)displayRange {
    NSRange displayRange = self.range ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[self.str componentsSeparatedByString:@" "] firstObject] ;
            NSUInteger numberOfmark = prefix.length ;
            displayRange = NSMakeRange(self.range.location + 1 + numberOfmark, self.range.length - 1 - numberOfmark) ;
        }
            break;
            
        default:
            break;
    }
    
    return displayRange ;
}

@end






static int kDefaultFontSize = 16 ;
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
    return [UIFont systemFontOfSize:kDefaultFontSize] ;
}

- (UIFont *)itatlicFont {
    NSDictionary *fontDict = @{UIFontDescriptorMatrixAttribute:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0)]} ;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontDict] ;
    return [UIFont fontWithDescriptor:attributeFontDescriptor size:kDefaultFontSize] ;
}

- (NSDictionary *)defaultStyle {
    return @{NSFontAttributeName : [self defaultFont]};
}

- (NSRegularExpression *)getRegularExpressionFromMarkdownSyntaxType:(MarkdownSyntaxType)type {
    switch (type) {
        case MarkdownSyntaxUnknown:
            return nil;
        case MarkdownSyntaxNewLine:
            return regexp("^\\n+", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxHeaders:
            return regexp("^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)", NSRegularExpressionAnchorsMatchLines); //(#{1,6})\s*(.*?)\s*$
//^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)
            
        
        case MarkdownSyntaxBold:
            return regexp("(\\*\\*|__)(.*?)\\1", 0);
        case MarkdownSyntaxItalic:
            return regexp("(\\*|_)(.*?)\\1", 0);
        case MarkdownSyntaxDeletions:
            return regexp("\\~\\~(.*?)\\~\\~", 0);
        case MarkdownSyntaxInlineCode:
            return regexp("`(.*?)`", 0);
            
            
        case MarkdownSyntaxLinks:
            return regexp("\\[([^\\[]+)\\]\\(([^\\)]+)\\)", 0);
        case MarkdownSyntaxQuotes:
            return regexp("\\:\\\"(.*?)\\\"\\:", 0);
        
        case MarkdownSyntaxCodeBlock:
            return regexp("```([\\s\\S]*?)```", 0);
        case MarkdownSyntaxBlockquotes:
            return regexp("\n(&gt;|\\>)(.*)",0);
        case MarkdownSyntaxULLists:
            return regexp("^( *)([*+-]) [\\s\\S]+?(?:hr|def|\\n{2,}(?! )(?!\\1[*+-] )\\n*|\\s*$)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxOLLists:
            return regexp("^[0-9]+\\.(.*)", NSRegularExpressionAnchorsMatchLines);
        
        case NumberOfMarkdownSyntax: break ;
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
            
        case MarkdownSyntaxNewLine:
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
        
        case MarkdownSyntaxBold:
            resultDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:kDefaultFontSize]};
            break ;
        case MarkdownSyntaxItalic:
            resultDic = @{NSFontAttributeName : [self itatlicFont]};
            break ;
            
        case MarkdownSyntaxDeletions:
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            break ;
        case MarkdownSyntaxInlineCode:
            resultDic = @{NSBackgroundColorAttributeName : UIColorHex(@"f0f1f1"),
                          NSFontAttributeName : paragraphFont
                          };
            break ;
            
            
            
        case MarkdownSyntaxLinks:
            resultDic = @{NSForegroundColorAttributeName : [UIColor blueColor],
                          NSFontAttributeName : paragraphFont
                          };
            break ;
            
        case MarkdownSyntaxQuotes:
            resultDic = @{NSForegroundColorAttributeName : [UIColor lightGrayColor],
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
            
        case NumberOfMarkdownSyntax: break ;
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
            NSUInteger numberOfmark = [self.class rangesOfString:prefix referString:@"#"].count ;
            str = STR_FORMAT(@"H%lu",(unsigned long)numberOfmark) ;
            if (![model.str containsString:@" "] || numberOfmark > 6) str = @"" ;
            
        }  break ;
        case MarkdownSyntaxBold: str = @"B" ; break ;
        case MarkdownSyntaxItalic: str = @"I" ; break ;
            
        case MarkdownSyntaxDeletions: str = @"D" ; break ;
        case MarkdownSyntaxInlineCode: str = @"inline code" ; break ;
            
        case MarkdownSyntaxLinks: str = @"link" ; break ;
        case MarkdownSyntaxQuotes: str = @"q" ; break ;
        case MarkdownSyntaxCodeBlock: str = @"code block" ; break ;
        case MarkdownSyntaxBlockquotes: str = @"block quotes" ; break ;
        
        case MarkdownSyntaxULLists: str = @"ul" ; break ;
        case MarkdownSyntaxOLLists: str = @"ol" ; break ;
        
        default: break ;
    }
    return str ;
}

+ (NSArray <NSValue *> *)rangesOfString:(NSString *)text referString:(NSString *)findText {
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:3];
    if (findText == nil && [findText isEqualToString:@""]){
        return nil;
    }
    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range
    if (rang.location != NSNotFound && rang.length != 0){
        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中
        NSRange rang1 = {0,0};
        NSInteger location = 0;
        NSInteger length = 0;
        for (int i = 0;; i++){
            if (0 == i){
                location = rang.location + rang.length;
                length = text.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            }
            else{
                location = rang1.location + rang1.length;
                length = text.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            //在一个range范围内查找另一个字符串的range
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            if (rang1.location == NSNotFound && rang1.length == 0){
                break;
            }
            else{
                //添加符合条件的location进数组
                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
            }
        }
        return arrayRanges;
    }
    return nil;
}


- (NSAttributedString *)parseText:(NSString *)text {
    NSArray *models = [self syntaxModelsForText:text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString beginEditing] ;
    [attributedString addAttributes:self.defaultStyle range:NSMakeRange(0, text.length)] ;
    
    for (MarkdownModel *model in models) {
        [attributedString addAttributes:[self attributesFromMarkdownSyntaxModel:model] range:model.displayRange] ;
    }
    [attributedString endEditing] ;
    
    return attributedString ;
}

@end
