//
//  MdBlockModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdBlockModel.h"
#import <XTlib/XTlib.h>
#import "MarkdownEditor.h"
#import "MarkdownEditor+OctToolbarUtil.h"
#import "XTMarkdownParser+Fetcher.h"

@implementation MdBlockModel

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str level:(int)level {
    MdBlockModel *model = [super modelWithType:type range:range str:str level:level] ;
    
    // 引用嵌套其他blk的处理
    if (model.type == MarkdownSyntaxBlockquotes) {
        XTMarkdownParser *parser = [XTMarkdownParser new] ;
        MarkdownModel *tmpModel = [model copy] ;
        NSUInteger cutNumber = 0 ;
        NSString *newStr ;
        
        NSString *prefix = [[tmpModel.str componentsSeparatedByString:@">"] firstObject] ;
        cutNumber = prefix.length ;
        newStr = [tmpModel.str substringFromIndex:cutNumber + 1] ;
        while ([newStr hasPrefix:@" "]) {
            newStr = [newStr substringFromIndex:1] ;
            cutNumber++ ;
        }
        
        tmpModel.str = newStr ;
        tmpModel.range = NSMakeRange(tmpModel.range.location + cutNumber + 1, tmpModel.range.length - cutNumber - 1) ;
        tmpModel.quoteAndList_Level ++ ;
        
        // 递归
        MarkdownModel *subModel = [parser parsingGetABlockStyleModelFromParaModel:tmpModel] ;
        if (subModel.type <= NumberOfMarkdownSyntax && subModel.type > 0) {            
            model.subBlkModel = subModel ;
        }
        tmpModel = nil ;
    }
    
    return model ;
}


- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: str = @"md_tb_bt_quote"     ; break ;
        case MarkdownSyntaxCodeBlock:   str = @"md_tb_bt_blkCode"   ; break ;
        
        default: break;
    }
    return str ;
}

- (NSDictionary *)attrQuoteBlockHideMarkWithLevel {
    int level = self.textIndentationPosition ;
    level++ ;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init] ;
    paraStyle.firstLineHeadIndent = 18 * level ;
    paraStyle.headIndent = 18 * level ;
    paraStyle.lineSpacing = 10 ;
    NSDictionary *tmpStyle = @{
                               NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                               NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                               NSFontAttributeName : [UIFont systemFontOfSize:.1] ,
                               NSParagraphStyleAttributeName : paraStyle,
                               } ;
    return tmpStyle ;
}

- (NSDictionary *)attrCodeBlockHideMark {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init] ;
    paraStyle.paragraphSpacing = 0 ;
    NSDictionary *tmpStyle = @{
                                NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                                NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                                NSFontAttributeName : [UIFont systemFontOfSize:.1] ,
                                NSParagraphStyleAttributeName : paraStyle,
                               } ;
    return tmpStyle ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: {
            [attributedString addAttributes:configuration.editorThemeObj.quoteStyle range:self.range] ;
            
            // hide ">" mark
            NSRegularExpression *expression = regexp("(\\>\\s)|(\\>)", 0) ;
//            NSRegularExpression *expression = regexp("(\\>)", 0) ;
            NSArray *matches = [expression matchesInString:self.str options:0 range:NSMakeRange(0, [self.str length])] ;
            for (NSTextCheckingResult *result in matches) {
                NSRange bqRange = NSMakeRange(location + result.range.location, result.range.length) ;
                [attributedString addAttributes:[self attrQuoteBlockHideMarkWithLevel] range:bqRange] ;
            }
        }
            break ;
        case MarkdownSyntaxCodeBlock: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
            
            resultDic = [self attrCodeBlockHideMark] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + length - 3, 3)] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSDictionary *resultDic = configuration.editorThemeObj.basicStyle ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxBlockquotes: {
            [attributedString addAttributes:configuration.editorThemeObj.quoteStyle range:self.range] ;
            
            // hide ">" mark
            NSRegularExpression *expression = regexp("(\\>\\s)|(\\>)", 0) ;
            NSArray *matches = [expression matchesInString:self.str options:0 range:NSMakeRange(0, [self.str length])] ;
            for (NSTextCheckingResult *result in matches) {
                NSRange bqRange = NSMakeRange(location + result.range.location, result.range.length) ;
                [attributedString addAttributes:[self attrQuoteBlockHideMarkWithLevel] range:bqRange] ;
            }
        }
            break ;
        case MarkdownSyntaxCodeBlock: {
//            NSRange rangeTmp = NSMakeRange(location + 3, length - 6) ;
//            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:rangeTmp] ;
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}



+ (void)toolbarEventQuoteBlock:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"> " atIndex:editor.selectedRange.location] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 1, 0) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        return ;
    }
    // replace
    if (paraModel.type == MarkdownSyntaxBlockquotes) return ;
    [tmpString insertString:@"> " atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:paraModel.range.location textView:editor] ;
    MarkdownModel *modelParse = [editor.parser modelForModelListBlockFirst] ;
    [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
    editor.selectedRange = NSMakeRange(modelParse.range.length + modelParse.range.location, 0) ;
}

+ (void)toolbarEventCodeBlock:(MarkdownEditor *)editor {
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"```\n \n```" atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        id modelParse = [editor.parser modelForModelListBlockFirst] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 4, 0) ;
        [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxCodeBlock) return ;
    
    [tmpString insertString:@"\n```" atIndex:paraModel.range.location + paraModel.range.length] ;
    [tmpString insertString:@"```\n" atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
    MarkdownModel *modelParse = [editor.parser modelForModelListBlockFirst] ;
    [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
    editor.selectedRange = NSMakeRange(modelParse.range.length + modelParse.range.location, 0) ;
}






+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range {
    
    int result = [self nest_keyboardEnterTypedInTextView:textView modelInPosition:aModel shouldChangeTextInRange:range] ;
    if (result != 100) return result ;
    
    NSMutableString *tmpString = [textView.text mutableCopy] ;
    NSString *insertQuoteString = @"\n> " ;
    
    if (aModel.type == MarkdownSyntaxBlockquotes) {
        if ([aModel.str isEqualToString:@"> "]) {     // 两下回车, 删除mark
            [tmpString deleteCharactersInRange:NSMakeRange(range.location - aModel.str.length, aModel.str.length)] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location - aModel.str.length textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location - aModel.str.length + 1, 0) ;
            return NO ;
        }
        
        [tmpString insertString:insertQuoteString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertQuoteString.length, 0) ;
        
        return NO ;
    }
    
    return 100 ; // 未知情况, 传到下一个model去处理
}


// 列表引用 的嵌套 回车处理
+ (int)nest_keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                         modelInPosition:(MarkdownModel *)aModel
                 shouldChangeTextInRange:(NSRange)range {
    
    NSMutableString *tmpString = [textView.text mutableCopy] ;
    
    //1. 先去获得model.str最前面的所有mark
    NSString *allMarkPreWithoutSpaceBefore = @"" ;
    int iLengh = 0 ;
    while (iLengh < aModel.str.length) {
        NSString *sub = [aModel.str substringWithRange:NSMakeRange(iLengh, 1)] ;
        if ([sub isEqualToString:@"*"] || [sub isEqualToString:@"-"] || [sub isEqualToString:@"+"] ||
            [sub isEqualToString:@" "] ||
            [sub isEqualToString:@">"] ||
            [sub isEqualToString:@"."] || [[[NSNumberFormatter alloc] init] numberFromString:sub] != NULL
            ) {
            iLengh ++ ;
            if ([sub isEqualToString:@" "] && allMarkPreWithoutSpaceBefore.length == 0) continue ;
            allMarkPreWithoutSpaceBefore = [allMarkPreWithoutSpaceBefore stringByAppendingString:sub] ;
            
        }
        else break ;
    }
    
    if (
        (aModel.type == MarkdownSyntaxOLLists || aModel.type == MarkdownSyntaxULLists)
         &&
         aModel.markIndentationPosition > 1
        ) {
        // 非1级的列表格式
        if (2 * (aModel.markIndentationPosition - 1) + allMarkPreWithoutSpaceBefore.length == aModel.str.length) {
            // 缩进退一级
            [tmpString deleteCharactersInRange:NSMakeRange(aModel.range.location, 2)] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location - 2 textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location - 2, 0) ;
            return NO ;
        }
        else {
            if (aModel.type == MarkdownSyntaxOLLists) {
                int countForOL = [[[allMarkPreWithoutSpaceBefore componentsSeparatedByString:@"."] firstObject] intValue] ;
                countForOL ++ ;
                allMarkPreWithoutSpaceBefore = XT_STR_FORMAT(@"%d.",countForOL) ;
            }
            
            NSString *markWillAdd = @"\n" ;
            for (int i = 1; i < aModel.markIndentationPosition ; i++) {
                markWillAdd = [markWillAdd stringByAppendingString:@"  "] ;
            }
            markWillAdd = [markWillAdd stringByAppendingString:allMarkPreWithoutSpaceBefore] ;
            if (aModel.subBlkModel == nil) markWillAdd = [markWillAdd stringByAppendingString:@" "] ;
            [tmpString insertString:markWillAdd atIndex:range.location] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location + markWillAdd.length textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location + markWillAdd.length, 0) ;
            return NO ;
        }
    }
    
    //是否嵌套了 引用,列表组合
    if (aModel.wholeNestCountForquoteAndList > 0) {
        //1. 先去获得model.str最前面的所有mark
        NSString *allMarkPre = @"" ;
        int iLengh = 0 ;
        while (iLengh < aModel.str.length) {
            NSString *sub = [aModel.str substringWithRange:NSMakeRange(iLengh, 1)] ;
            if ([sub isEqualToString:@"*"] || [sub isEqualToString:@"-"] || [sub isEqualToString:@"+"] ||
                [sub isEqualToString:@" "] ||
                [sub isEqualToString:@">"] ||
                [sub isEqualToString:@"."] || [[[NSNumberFormatter alloc] init] numberFromString:sub] != NULL
                ) {
                allMarkPre = [allMarkPre stringByAppendingString:sub] ;
                iLengh ++ ;
            }
            else break ;
        }
        
        if ([allMarkPre isEqualToString:aModel.str]) {
            //2. 当mark和model相同, 退一级 嵌套.
            NSUInteger iLengh = 0 ; //allMarkPre.length - 1 ;
            while (iLengh < aModel.str.length) {
                NSString *aChar = [allMarkPre substringWithRange:NSMakeRange(allMarkPre.length - 1 - iLengh, 1)] ;
                iLengh ++ ;
                if (![aChar isEqualToString:@" "]) break ;
            }
            [tmpString deleteCharactersInRange:aModel.range] ;
            allMarkPre = [allMarkPre substringToIndex:aModel.length - iLengh] ;
            [tmpString insertString:allMarkPre atIndex:aModel.location] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:aModel.location + allMarkPre.length textView:textView] ;
            textView.selectedRange = NSMakeRange(aModel.location + allMarkPre.length, 0) ;
        }
        else {
            //3. 当mark和model不同, 重复上面的嵌套结构
            NSLog(@"allMarkPre : %@",allMarkPre) ;
            allMarkPre = [@"\n" stringByAppendingString:allMarkPre] ;
            [tmpString insertString:allMarkPre atIndex:range.location] ;
            [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:textView] ;
            textView.selectedRange = NSMakeRange(range.location + allMarkPre.length, 0) ;
        }
        return NO ;
        
    }
    
    
    return 100 ; // 未知情况, 传到下一个model去处理
}



@end
