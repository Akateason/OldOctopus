//
//  RegexHighlightView.m
//  Simple Objective-C Syntax Highlighter
//
//  Created by Kristian Kraljic on 30/08/12.
//  Copyright (c) 2012 Kristian Kraljic (dikrypt.com, ksquared.de). All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person 
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "RegexHighlightView.h"
#import <XTlib/XTlib.h>
#import "MDThemeConfiguration.h"

#define EMPTY @""

NSString *const kRegexHighlightViewTypeText = @"text";
NSString *const kRegexHighlightViewTypeBackground = @"background";
NSString *const kRegexHighlightViewTypeComment = @"comment";
NSString *const kRegexHighlightViewTypeDocumentationComment = @"documentation_comment";
NSString *const kRegexHighlightViewTypeDocumentationCommentKeyword = @"documentation_comment_keyword";
NSString *const kRegexHighlightViewTypeString = @"string";
NSString *const kRegexHighlightViewTypeCharacter = @"character";
NSString *const kRegexHighlightViewTypeNumber = @"number";
NSString *const kRegexHighlightViewTypeKeyword = @"keyword";
NSString *const kRegexHighlightViewTypePreprocessor = @"preprocessor";
NSString *const kRegexHighlightViewTypeURL = @"url";
NSString *const kRegexHighlightViewTypeAttribute = @"attribute";
NSString *const kRegexHighlightViewTypeProject = @"project";
NSString *const kRegexHighlightViewTypeOther = @"other";

@interface RegexHighlightView() <UITextViewDelegate>
- (NSAttributedString*)highlightText:(NSString*)stringIn;
+ (NSDictionary*)defaultDefinition;
@end



static NSMutableDictionary* highlightThemes;

@implementation RegexHighlightView
@synthesize highlightColor;
@synthesize highlightDefinition;

-(void)setHighlightDefinitionWithContentsOfFile:(NSString*)newPath {
    self.textColor = [UIColor clearColor];
    self.highlightDefinition = [NSDictionary dictionaryWithContentsOfFile:newPath] ;
}

- (id)initWithText:(NSString *)text
             theme:(RegexHighlightViewTheme)theme
              path:(NSString *)newPath
{
    self = [super init] ;
    if(self) {
        self.delegate = self ;
        [self setHighlightTheme:theme] ;
        [self setHighlightDefinitionWithContentsOfFile:newPath] ;
        self.textColor = [UIColor clearColor];
        NSAttributedString *attr = [self highlightText:text] ;
        self.attributedText = attr ;
        self.font = [UIFont systemFontOfSize:16] ;
    }
    return self;
}


- (NSAttributedString *)highlightText:(NSString*)string {
    UIColor* textColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .75) ;
    
    //Create a mutable attribute string to set the highlighting
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5 ;
    NSDictionary *dic = @{NSForegroundColorAttributeName : textColor ,
                          NSFontAttributeName : [UIFont systemFontOfSize:16] ,
                          NSParagraphStyleAttributeName : paragraphStyle ,} ;
    NSMutableAttributedString *coloredString = [[NSMutableAttributedString alloc] initWithString:string attributes:dic];
    NSRange range = NSMakeRange(0,[string length]) ;
    
    [coloredString beginEditing] ;
    
    //Define the definition to use
    NSDictionary *definition = self.highlightDefinition ;
    if(!(definition=self.highlightDefinition)) definition = [RegexHighlightView defaultDefinition];
    
    //For each definition entry apply the highlighting to matched ranges
    for(NSString* key in definition) {
        NSString* expression = [definition objectForKey:key];
        if(!expression||[expression length]<=0) continue ;
        NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for (NSTextCheckingResult* match in matches) {
            UIColor* textColor = nil;
            //Get the text color, if it is a custom key and no color was defined, choose black
            if(!self.highlightColor||!(textColor=([self.highlightColor objectForKey:key])))
                if(!(textColor=[[RegexHighlightView highlightTheme:kRegexHighlightViewThemeDefault] objectForKey:key]))
                    textColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .75) ;
            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:[match rangeAtIndex:0]];

            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5 ;
            [coloredString addAttributes:@{NSForegroundColorAttributeName : textColor ,
                                           NSFontAttributeName : [UIFont systemFontOfSize:16] ,
                                           NSParagraphStyleAttributeName : paragraphStyle ,
                                           }
                                   range:match.range] ;

        }
    }
    
    [coloredString endEditing] ;
    
    return coloredString ;
}

- (void)setHighlightTheme:(RegexHighlightViewTheme)theme {
    self.textColor = [UIColor clearColor];
    self.highlightColor = [RegexHighlightView highlightTheme:theme];
    
    UIColor *backgroundColor = [self.highlightColor objectForKey:kRegexHighlightViewTypeBackground];
    if (backgroundColor) self.backgroundColor = backgroundColor;
    else self.backgroundColor = [UIColor whiteColor];
}

+(NSDictionary*)highlightTheme:(RegexHighlightViewTheme)theme {
    //Check if the highlight theme has already been defined
    NSDictionary* themeColor = nil;
    if (!highlightThemes) highlightThemes = [NSMutableDictionary dictionary];
    if ((themeColor = [highlightThemes objectForKey:[NSNumber numberWithInt:theme]])) return themeColor;
    
    //If not define the theme and return it
    switch(theme) {
        case kRegexHighlightViewThemeBasic:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:0.0/255 green:142.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:0.0/255 green:142.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:0.0/255 green:142.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:181.0/255 green:37.0/255 blue:34.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:49.0/255 green:149.0/255 blue:172.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:49.0/255 green:149.0/255 blue:172.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemeDefault:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, 0.75),kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:0.0/255 green:76.0/255 blue:29.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:211.0/255 green:45.0/255 blue:38.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:188.0/255 green:49.0/255 blue:156.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:120.0/255 green:72.0/255 blue:48.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:150.0/255 green:125.0/255 blue:65.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:77.0/255 green:129.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemeDusk:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:40.0/255 green:43.0/255 blue:52.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:230.0/255 green:66.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:195.0/255 green:55.0/255 blue:149.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:211.0/255 green:142.0/255 blue:99.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:35.0/255 green:63.0/255 blue:208.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:103.0/255 green:135.0/255 blue:142.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:146.0/255 green:199.0/255 blue:119.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:0.0/255 green:175.0/255 blue:199.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemeLowKey:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:133.0/255 green:63.0/255 blue:98.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:24.0/255 green:49.0/255 blue:168.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:35.0/255 green:93.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:87.0/255 green:127.0/255 blue:164.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:87.0/255 green:127.0/255 blue:164.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemeMidnight:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:255.0/255 green:68.0/255 blue:77.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:139.0/255 green:138.0/255 blue:247.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:139.0/255 green:138.0/255     blue:247.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:224.0/255 green:59.0/255 blue:160.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:237.0/255 green:143.0/255 blue:100.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:36.0/255 green:72.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:79.0/255 green:108.0/255 blue:132.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:0.0/255 green:249.0/255 blue:161.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:0.0/255 green:179.0/255 blue:248.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemePresentation:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:158.0/255 green:32.0/255 blue:32.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:140.0/255 green:34.0/255 blue:96.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:125.0/255 green:72.0/255 blue:49.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:150.0/255 green:125.0/255 blue:65.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:77.0/255 green:129.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemePrinting:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:113.0/255 green:113.0/255 blue:113.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:113.0/255 green:113.0/255 blue:113.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:112.0/255 green:112.0/255 blue:112.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:71.0/255 green:71.0/255 blue:71.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:71.0/255 green:71.0/255 blue:71.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:108.0/255 green:108.0/255 blue:108.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:129.0/255 green:129.0/255 blue:129.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:86.0/255 green:86.0/255 blue:86.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case kRegexHighlightViewThemeSunset:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                    [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                    [UIColor colorWithRed:255.0/255 green:252.0/255 blue:236.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                    [UIColor colorWithRed:208.0/255 green:134.0/255 blue:59.0/255 alpha:1],kRegexHighlightViewTypeComment,
                    [UIColor colorWithRed:208.0/255 green:134.0/255 blue:59.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                    [UIColor colorWithRed:190.0/255 green:116.0/255 blue:55.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                    [UIColor colorWithRed:234.0/255 green:32.0/255 blue:24.0/255 alpha:1],kRegexHighlightViewTypeString,
                    [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                    [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                    [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                    [UIColor colorWithRed:119.0/255 green:121.0/255 blue:148.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                    [UIColor colorWithRed:85.0/255 green:99.0/255 blue:179.0/255 alpha:1],kRegexHighlightViewTypeURL,
                    [UIColor colorWithRed:58.0/255 green:76.0/255 blue:166.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                    [UIColor colorWithRed:196.0/255 green:88.0/255 blue:31.0/255 alpha:1],kRegexHighlightViewTypeProject,
                    [UIColor colorWithRed:196.0/255 green:88.0/255 blue:31.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
    }
    if(themeColor) {
        [highlightThemes setObject:themeColor forKey:[NSNumber numberWithInt:theme]];
        return themeColor;
    } else return nil;
}

+ (NSDictionary*)defaultDefinition {
    //It is recommended to use an ordered dictionary, because the highlighting will take place in the same order the dictionary enumerator returns the definitions
    NSMutableDictionary* definition = [NSMutableDictionary dictionary];
    [definition setObject:@"(?<!\\w)(and|or|xor|for|do|while|foreach|as|return|die|exit|if|then|else|elseif|new|delete|try|throw|catch|finally|class|function|string|array|object|resource|var|bool|boolean|int|integer|float|double|real|string|array|global|const|static|public|private|protected|published|extends|switch|true|false|null|void|this|self|struct|char|signed|unsigned|short|long|print)(?!\\w)" forKey:kRegexHighlightViewTypeKeyword];
    [definition setObject:@"((https?|mailto|ftp|file)://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?)" forKey:kRegexHighlightViewTypeURL];
    [definition setObject:@"\\b((NS|UI|CG)\\w+?)" forKey:kRegexHighlightViewTypeProject];
    [definition setObject:@"(\\.[^\\d]\\w+)" forKey:kRegexHighlightViewTypeAttribute];    
    [definition setObject:@"(?<!\\w)(((0x[0-9a-fA-F]+)|(([0-9]+\\.?[0-9]*|\\.[0-9]+)([eE][-+]?[0-9]+)?))[fFlLuU]{0,2})(?!\\w)" forKey:kRegexHighlightViewTypeNumber];
    [definition setObject:@"('.')" forKey:kRegexHighlightViewTypeCharacter];
    [definition setObject:@"(@?\"(?:[^\"\\\\]|\\\\.)*\")" forKey:kRegexHighlightViewTypeString];
    [definition setObject:@"//[^\"\\n\\r]*(?:\"[^\"\\n\\r]*\"[^\"\\n\\r]*)*[\\r\\n]" forKey:kRegexHighlightViewTypeComment];
    [definition setObject:@"(/\\*|\\*/)" forKey:kRegexHighlightViewTypeDocumentationCommentKeyword];
    [definition setObject:@"/\\*(.*?)\\*/" forKey:kRegexHighlightViewTypeDocumentationComment];
    [definition setObject:@"(#.*?)[\r\n]" forKey:kRegexHighlightViewTypePreprocessor];
    [definition setObject:@"(Kristian|Kraljic)" forKey:kRegexHighlightViewTypeOther];
    return definition;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSRange selectedRange = self.selectedRange ;
    self.attributedText = [self highlightText:self.text] ;
    self.selectedRange = selectedRange ;
    self.font = [UIFont systemFontOfSize:16] ;
    
//    if (self.regexDelegate) {
//        [self.regexDelegate textChanged:self.text] ;
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //Only update the text if the text changed
    NSString* newText = [text stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
    if(![newText isEqualToString:text]) {
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:newText];
        return NO;
    }
    return YES;
}

@end
