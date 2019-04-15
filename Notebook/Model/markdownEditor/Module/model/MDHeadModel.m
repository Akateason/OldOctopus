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
            str = STR_FORMAT(@"md_tb_bt_h%lu",(unsigned long)numberOfmark) ;
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

    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
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
            NSRange markRange = NSMakeRange(location, numberOfmark + 1) ;
            if (numberOfmark + 1 > attributedString.length) return attributedString ;
            
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:markRange] ;
        }
            break;
            
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
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
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:markRange] ;
        }
            break;
            
        default:
            break;
    }
    
    return attributedString ;
}

+ (void)makeHeaderWithSize:(NSString *)mark editor:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:mark atIndex:editor.selectedRange.location] ;
        [editor.markdownPaser parseText:tmpString position:editor.selectedRange.location + mark.length textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + mark.length, 0) ;
        return ;
    }
    
    // replace
    [tmpString insertString:mark atIndex:paraModel.range.location] ;
    MarkdownModel *model = [editor.markdownPaser modelForModelListBlockFirst:[editor.markdownPaser parseText:tmpString position:paraModel.range.location textView:editor]] ;
    [editor doSomethingWhenUserSelectPartOfArticle:model] ;
    editor.selectedRange = NSMakeRange(model.range.length + model.range.location, 0) ;
}

@end
