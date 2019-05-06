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

- (NSDictionary *)xt_invisibleListStyle {
    int num = self.countForSpace / 2 ;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.firstLineHeadIndent = 16 * num ;
    NSDictionary *dic
     = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_markColor),
                                NSFontAttributeName : [UIFont systemFontOfSize:0.1] ,
                                NSParagraphStyleAttributeName: paragraphStyle
                                } ;
    return dic ;
}




- (int)countForSpace {
    NSString *prefix ;
    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            prefix = [[self.str componentsSeparatedByString:@"."] firstObject] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            prefix = [[self.str componentsSeparatedByString:@"*"] firstObject] ;
            if (!prefix) [[self.str componentsSeparatedByString:@"+"] firstObject] ;
            if (!prefix) [[self.str componentsSeparatedByString:@"-"] firstObject] ;
        }
            break ;
        case MarkdownSyntaxTaskLists: {
            prefix = [[self.str componentsSeparatedByString:@"*"] firstObject] ;
        }
            break ;
    }
    _countForSpace = (int)([prefix xt_searchAllRangesWithText:@" "].count) ;
        
    return _countForSpace ;
}

- (NSRange)realRange {
    if (_realRange.length == 0) {
        if ([self.str hasPrefix:@" "]) {
            _realRange = NSMakeRange(self.range.location + self.countForSpace, self.range.length - self.countForSpace) ;
        }
        else {
            _realRange = self.range ;
        }
    }
    return _realRange ;
}

- (NSRange)markWillHiddenRange {
    if (_markWillHiddenRange.length == 0) {
        NSUInteger countForMark = self.countForSpace + 1 ;
        _markWillHiddenRange = NSMakeRange(self.range.location, countForMark) ;
    }
    return _markWillHiddenRange ;
}

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    switch (self.type) {
        case MarkdownSyntaxOLLists:     str = @"md_tb_bt_olist"     ; break ;
        case MarkdownSyntaxULLists:     str = @"md_tb_bt_ulist"     ; break ;
        case MarkdownSyntaxTaskLists:   str = @"md_tb_bt_tasklist"  ; break ;
        default: break ;
    }
    return str ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {
    
    MDThemeConfiguration *configuration = [MDThemeConfiguration sharedInstance] ;
    NSDictionary *resultDic = [self defultStyle] ;
    UIFont *paragraphFont = [self defaultFont] ;

    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            // number
            [attributedString addAttributes:self.xt_invisibleListStyle range:self.markWillHiddenRange] ;
        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:self.xt_invisibleListStyle range:self.markWillHiddenRange] ;
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

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    MDThemeConfiguration *configuration = [MDThemeConfiguration sharedInstance] ;
    NSDictionary *resultDic = [self defultStyle] ;
    UIFont *paragraphFont = [self defaultFont] ;
    
    switch (self.type) {
        case MarkdownSyntaxOLLists: {
            // number
            [attributedString addAttributes:self.xt_invisibleListStyle range:self.markWillHiddenRange] ;

        }
            break ;
        case MarkdownSyntaxULLists: {
            [attributedString addAttributes:self.xt_invisibleListStyle range:self.markWillHiddenRange] ;
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
