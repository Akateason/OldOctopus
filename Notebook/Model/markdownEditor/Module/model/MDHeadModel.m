//
//  MDHeadModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDHeadModel.h"
#import "MarkdownEditor.h"
#import "MarkdownEditor+UtilOfToolbar.h"


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
            
        default: break;
    }
    
    return str ;
}

- (NSString *)prefixOfTitle {
    return [[self.str componentsSeparatedByString:@" "] firstObject] ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {

    NSDictionary *resultDic = configuration.basicStyle ;
//    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
//    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [self prefixOfTitle] ;
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
            
            // hide "# " marks
            NSRange markRange = NSMakeRange(location, numberOfmark+1) ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:markRange] ;
        }
            break;
            
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    //    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
//    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [self prefixOfTitle] ;
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
            
        default:
            break;
    }
    
    return attributedString ;
}

//- (void)doToolbarEventForEditor:(MarkdownEditor *)editor {
//
//}

+ (void)makeHeaderWithSize:(NSString *)mark editor:(MarkdownEditor *)editor {
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    // add
    if (!paraModel) {
        [tmpString insertString:mark atIndex:editor.selectedRange.location] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + mark.length, 0) ;
        [editor.markdownPaser parseText:tmpString position:paraModel.range.location textView:editor] ;
        return ;
    }
    
    // replace
    [tmpString insertString:mark atIndex:paraModel.range.location] ;
    [editor.markdownPaser parseText:tmpString position:paraModel.range.location textView:editor] ;
    [editor doSomethingWhenUserSelectPartOfArticle] ;
}



@end
