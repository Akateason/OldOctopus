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
#import "XTMarkdownParser+Fetcher.h"

@implementation MdListModel

- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {
    
    MDThemeConfiguration *configuration = [MDThemeConfiguration sharedInstance] ;
    NSDictionary *resultDic = [self defultStyle] ;
    UIFont *paragraphFont = [self defaultFont] ;

    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            [attributedString addAttributes:configuration.editorThemeObj.listInvisibleMarkStyle range:NSMakeRange(self.location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.editorThemeObj.listInvisibleMarkStyle range:NSMakeRange(self.location, 2)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            NSInteger markLoc = [[self.str componentsSeparatedByString:@"]"] firstObject].length + 1 ;
            [attributedString addAttributes:configuration.editorThemeObj.listInvisibleMarkStyle range:NSMakeRange(self.location, markLoc)] ;
            
            if (self.taskItemSelected) {
                resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                              NSFontAttributeName : paragraphFont
                              };
                [attributedString addAttributes:resultDic range:NSMakeRange(self.location + markLoc, self.length - markLoc)] ;
            }
        }
            break ;
        
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    MDThemeConfiguration *configuration = [MDThemeConfiguration sharedInstance] ;
    NSDictionary *resultDic = [self defultStyle] ;
    UIFont *paragraphFont = [self defaultFont] ;
    
    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            // number
            NSString *prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
            NSUInteger lenOfMark = prefix.length + 1 ;
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(self.location, lenOfMark + 1)] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(self.location, 2)] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            NSInteger markLoc = [[self.str componentsSeparatedByString:@"]"] firstObject].length + 1 ;
            [attributedString addAttributes:configuration.editorThemeObj.listInvisibleMarkStyle range:NSMakeRange(self.location, markLoc)] ;
            
            if (self.taskItemSelected) {
                resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                              NSFontAttributeName : paragraphFont
                              };
                [attributedString addAttributes:resultDic range:NSMakeRange(self.location + markLoc, self.range.length - markLoc)] ;
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
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"* [ ]  " atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 6, 0) ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxTaskLists) return ;
    [tmpString insertString:@"* [ ] " atIndex:paraModel.range.location] ;
    
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:paraModel.range.location textView:editor] ;
    MarkdownModel *aModel = [editor.parser modelForModelListBlockFirst] ;
    editor.selectedRange = NSMakeRange(aModel.range.location + aModel.range.length, 0) ;
}

+ (void)toolbarEventForUlist:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"*  " atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 2, 0) ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxULLists) return ;
    [tmpString insertString:@"* " atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:paraModel.range.location textView:editor] ;
    MarkdownModel *aModel = [editor.parser modelForModelListBlockFirst] ;
    editor.selectedRange = NSMakeRange(aModel.range.length + aModel.range.location, 0) ;
}

+ (void)toolbarEventForOrderList:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    
    int orderNum = 0 ;
    MarkdownModel *lastParaModel = [editor lastOneParagraphMarkdownModel] ;
    if (lastParaModel.type == MarkdownSyntaxOLLists) {
        orderNum = [[[lastParaModel.str componentsSeparatedByString:@"."] firstObject] intValue] ;
    }
    orderNum ++ ;
    
    NSString *orderStr = STR_FORMAT(@"%d",orderNum) ;
    // add
    if (!paraModel) {
        [tmpString insertString:STR_FORMAT(@"%@.  ",orderStr) atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + orderStr.length + 2, 0) ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxOLLists) return ;
    [tmpString insertString:STR_FORMAT(@"%@. ",orderStr) atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:paraModel.range.location textView:editor] ;
    MarkdownModel *aModel = [editor.parser modelForModelListBlockFirst] ;
    editor.selectedRange = NSMakeRange(aModel.range.length + aModel.range.location, 0) ;
}

@end
