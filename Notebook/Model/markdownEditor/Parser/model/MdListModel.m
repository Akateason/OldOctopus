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
#import "MarkdownEditor+OctToolbarUtil.h"
#import "XTMarkdownParser+Fetcher.h"

@implementation MdListModel
@synthesize textIndentationPosition = _textIndentationPosition ;

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str level:(int)level {
    MdListModel *model = [super modelWithType:type range:range str:str level:level] ;
    [model setupCountForSpace] ; // setup countForSpace
    
    // 列表嵌套的处理
    if (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists) {
        XTMarkdownParser *parser = [XTMarkdownParser new] ;
        MarkdownModel *tmpModel = [model copy] ;
        NSString *cuttedlistMarkStr = [model.str substringFromIndex:model.markWillHiddenRange.length] ;
        tmpModel.str = cuttedlistMarkStr ;
        tmpModel.range = NSMakeRange(tmpModel.range.location + model.markWillHiddenRange.length, tmpModel.range.length - model.markWillHiddenRange.length) ;
        if ([str hasPrefix:@" "]) {
            // 最外部的列表是否是个嵌套列表
            int findSpaceCount = 0 ;
            while (1) {
                NSString *strSpace = [str substringWithRange:NSMakeRange(findSpaceCount, 1)] ;
                if (![strSpace isEqualToString:@" "]) break ;
                findSpaceCount ++ ;
                tmpModel.quoteAndList_Level ++ ; //
            }
        }
        else {
            tmpModel.quoteAndList_Level ++ ; //
        }
        
        // 递归
        MarkdownModel *subModel = [parser parsingGetABlockStyleModelFromParaModel:tmpModel] ;
        if (subModel.type <= NumberOfMarkdownSyntax && subModel.type > 0) {
            model.subBlkModel = subModel ;
        }
        tmpModel = nil ;
    }
    
    return model ;
}

- (int)markIndentationPosition {
    return ( self.quoteAndList_Level ?: (self.countForSpace / 2) ) + 1 ;
}

- (int)textIndentationPosition {
    return ( super.textIndentationPosition ?: (self.countForSpace / 2) ) + 1 ;
}

- (int)wholeNestCountForquoteAndList {
    return super.textIndentationPosition ;
}

- (void)setupCountForSpace {
    int idx = 0 ;
    while (1) {
        NSString *aChar = [self.str substringWithRange:NSMakeRange(idx, 1)] ;
        if ([aChar isEqualToString:@" "]) {
            idx++ ;
        }
        else {
            self.countForSpace = idx ;
            break ;
        }
    }
}

- (NSDictionary *)xt_invisibleListStyle {
    int num = self.textIndentationPosition ;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new] ;
    paragraphStyle.firstLineHeadIndent = 16 * num ;
    paragraphStyle.lineSpacing = 10 ; // 列表内的行间距为：10px
//    paragraphStyle.paragraphSpacing = kDefaultFontSize ;
    NSDictionary *dic = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_markColor, .75) ,                          
                          NSFontAttributeName : [UIFont systemFontOfSize:0.1] ,
                          NSParagraphStyleAttributeName: paragraphStyle
                          } ;
    return dic ;
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
        NSUInteger countRes = _countForSpace ;
        switch (self.type) {
            case MarkdownSyntaxOLLists: {
                countRes = ( [[[self.str componentsSeparatedByString:@"."] firstObject] length] + 2 ) ;
            }
                break ;
            case MarkdownSyntaxULLists: {
                countRes += 2 ;
            }
                break ;
            case MarkdownSyntaxTaskLists: {
                countRes = ( [[[self.str componentsSeparatedByString:@"]"] firstObject] length] + 1 ) ;
            }
                break ;
            default: break ;
        }
        _markWillHiddenRange = NSMakeRange(self.range.location, countRes) ;
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
            [attributedString addAttributes:self.xt_invisibleListStyle range:NSMakeRange(self.location, markLoc)] ;
            
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
            [attributedString addAttributes:self.xt_invisibleListStyle range:NSMakeRange(self.location, markLoc)] ;
            
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
    MarkdownModel *blkModel = [editor.parser modelForModelListBlockFirst] ;
    if (blkModel.type == MarkdownSyntaxULLists) {
        // del
        [editor cleanMarkOfParagraph] ;
        return ;
    }
    
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"* " atIndex:editor.selectedRange.location] ;
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
    MarkdownModel *blkModel = [editor.parser modelForModelListBlockFirst] ;
    if (blkModel.type == MarkdownSyntaxOLLists) {
        // del
        [editor cleanMarkOfParagraph] ;
        return ;
    }
    
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
        [tmpString insertString:STR_FORMAT(@"%@. ",orderStr) atIndex:editor.selectedRange.location] ;
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



// 单层列表, 嵌套处理在 blockModel 类中
+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range {

    NSMutableString *tmpString = [textView.text mutableCopy] ;
    NSString *insertULString = @"\n* " ;
    NSString *insertOLString = @"" ;
    NSString *insertTLString = @"\n* [ ]  " ; // 只有checkbox 多加一个空格. 为了展示问题
    
    if (aModel.type == MarkdownSyntaxULLists) {
        if (aModel.str.length == 2) {
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - aModel.str.length, aModel.str.length)] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location - aModel.str.length + 1 textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location - aModel.str.length + 1, 0) ;
            textView.typingAttributes = [MDThemeConfiguration sharedInstance].editorThemeObj.basicStyle ;
            return NO ;
        }
        
        insertULString = @"\n* " ;
        [tmpString insertString:insertULString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + insertULString.length textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertULString.length, 0) ;
        return NO ;
    }
    else if (aModel.type == MarkdownSyntaxOLLists) {
        NSString *preMark = [[aModel.str componentsSeparatedByString:@"."] firstObject] ;
        if (preMark.length + 2 == aModel.str.length) {
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - aModel.str.length, aModel.str.length)] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location - aModel.str.length + 1 textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location - aModel.str.length + 1, 0) ;
            textView.typingAttributes = [MDThemeConfiguration sharedInstance].editorThemeObj.basicStyle ;
            return NO ;
        }
        
        int orderNum = [preMark intValue] ;
        orderNum ++ ;
        NSString *orderStr = STR_FORMAT(@"%d",orderNum) ;
        insertOLString = STR_FORMAT(@"\n%@. ",orderStr) ;
        [tmpString insertString:insertOLString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + insertOLString.length textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertOLString.length, 0) ;
        return NO ;
    }
    else if (aModel.type == MarkdownSyntaxTaskLists) {
        if ([aModel.str hasPrefix:@"* [ ]  "]) {
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - aModel.str.length + 1, aModel.str.length)] ;
            [tmpString insertString:@"\n" atIndex:range.location - aModel.str.length + 1] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location - aModel.str.length + 1 textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location - aModel.str.length + 1, 0) ;
            textView.typingAttributes = [MDThemeConfiguration sharedInstance].editorThemeObj.basicStyle ;
            return NO ;
        }
        
        [tmpString insertString:insertTLString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + insertTLString.length - 1 textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertTLString.length - 1, 0) ; // 只有checkbox 多加一个空格. 为了展示问题
        return NO ;
    }

    return 100 ; // 未知情况, 传到下一个model去处理
}

@end
