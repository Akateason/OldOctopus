//
//  MdListModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdListModel.h"
#import <XTlib/XTlib.h>
#import "MarkdownEditor.h"
#import "MarkdownEditor+UtilOfToolbar.h"

@implementation MdListModel

- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
//    NSUInteger length = self.range.length ;

    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            NSInteger markLoc = [[self.str componentsSeparatedByString:@"]"] firstObject].length + 1 ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, markLoc)] ;
            
            if (self.taskItemSelected) {
                resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                              NSFontAttributeName : paragraphFont
                              };
                [attributedString addAttributes:resultDic range:NSMakeRange(location + markLoc, self.range.length - markLoc)] ;
            }
        }
            break ;
        
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                           config:(MDThemeConfiguration *)configuration {
    
    NSDictionary *resultDic = configuration.basicStyle ;
    UIFont *paragraphFont = configuration.font ;
    NSUInteger location = self.range.location ;
//    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            NSInteger markLoc = [[self.str componentsSeparatedByString:@"]"] firstObject].length + 1 ;
            [attributedString addAttributes:configuration.invisibleMarkStyle range:NSMakeRange(location, markLoc)] ;
            
            if (self.taskItemSelected) {
                resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                              NSFontAttributeName : paragraphFont
                              };
                [attributedString addAttributes:resultDic range:NSMakeRange(location + markLoc, self.range.length - markLoc)] ;
            }
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}





- (BOOL)taskItemSelected {
    if (self.type != MarkdownSyntaxTaskLists) return NO ;
        
    NSString *prefix = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
    return [prefix containsString:@"x"] ;
}

- (UIImage *)taskItemImageState {
    return [self taskItemSelected] ? [UIImage imageNamed:@"check-box-on"] : [UIImage imageNamed:@"check-box-off"] ;
}




+ (void)toolbarEventForTasklist:(MarkdownEditor *)editor {
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"* [ ]  " atIndex:editor.selectedRange.location] ;
        [editor.markdownPaser parseText:tmpString position:editor.selectedRange.location textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 6, 0) ;
        [editor doSomethingWhenUserSelectPartOfArticle] ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxTaskLists) return ;
    [tmpString insertString:@"* [ ] " atIndex:paraModel.range.location] ;
    [editor.markdownPaser parseText:tmpString position:paraModel.range.location textView:editor] ;
    [editor doSomethingWhenUserSelectPartOfArticle] ;
}

+ (void)toolbarEventForUlist:(MarkdownEditor *)editor {
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"*  " atIndex:editor.selectedRange.location] ;
        [editor.markdownPaser parseText:tmpString position:editor.selectedRange.location textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 2, 0) ;
        [editor doSomethingWhenUserSelectPartOfArticle] ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxULLists) return ;
    [tmpString insertString:@"* " atIndex:paraModel.range.location] ;
    [editor.markdownPaser parseText:tmpString position:paraModel.range.location textView:editor] ;
    [editor doSomethingWhenUserSelectPartOfArticle] ;
}

@end
