//
//  MdOtherModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdOtherModel.h"
#import <XTlib/XTlib.h>
#import "MarkdownEditor.h"
#import "MarkdownEditor+OctToolbarUtil.h"
#import "XTMarkdownParser+Fetcher.h"


@implementation MdOtherModel

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
//        case MarkdownSyntaxMultipleMath: str = @"数学"; break;
        case MarkdownSyntaxHr: str = @"md_tb_bt_sepline" ; break ;
//        case MarkdownSyntaxTable: str = @"表格1" ; break ;
// todo ,
        default: break;
    }
    return str ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {
    
    MDThemeConfiguration *configuration = MDThemeConfiguration.sharedInstance ;
    NSMutableDictionary *resultDic = [configuration.editorThemeObj.basicStyle mutableCopy] ;
    UIFont *paragraphFont = configuration.editorThemeObj.font ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxMultipleMath: {
            [resultDic setObject:XT_MD_THEME_COLOR_KEY(k_md_bgColor) forKey:NSForegroundColorAttributeName] ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break;
        case MarkdownSyntaxHr: {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 0;
            paragraphStyle.paragraphSpacing = kDefaultFontSize * 1.3;
            resultDic = @{NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                          NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                          NSFontAttributeName : configuration.editorThemeObj.font ,
                          NSParagraphStyleAttributeName : paragraphStyle
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break ;
        case MarkdownSyntaxTable: {
//            resultDic = @{NSBackgroundColorAttributeName : [UIColor redColor] } ;
            [attributedString addAttributes:[MDThemeConfiguration sharedInstance].editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;            
        default: break;
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
        case MarkdownSyntaxMultipleMath: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break;
        case MarkdownSyntaxHr: {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 0 ;
            paragraphStyle.paragraphSpacing = kDefaultFontSize * 1.3 ;
            resultDic = @{NSBackgroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                          NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_bgColor) ,
                          NSFontAttributeName : configuration.editorThemeObj.font ,
                          NSParagraphStyleAttributeName : paragraphStyle
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
        }
            break;        
        case MarkdownSyntaxTable: {
            [attributedString addAttributes:configuration.editorThemeObj.codeBlockStyle range:self.range] ;
        }
            break ;
            
        default:
            break;
    }
    
    return attributedString ;
}


+ (void)toolbarEventMath:(MarkdownEditor *)editor {
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    MarkdownModel *blkModel = [editor.parser modelForModelListBlockFirst] ;
    // delete
    if (blkModel.type == MarkdownSyntaxMultipleMath) {
        NSString *tmpPrefixStr = blkModel.str ;
        [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location + blkModel.range.length - 3, 3)] ;
        tmpPrefixStr = [[tmpPrefixStr componentsSeparatedByString:@"\n"] firstObject] ;
        [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location, tmpPrefixStr.length + 1)] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:blkModel.location + blkModel.length - 6 textView:editor] ;
        editor.selectedRange = NSMakeRange(blkModel.location + blkModel.length - 6, 0) ;
        editor.typingAttributes = [MDThemeConfiguration sharedInstance].editorThemeObj.basicStyle ;
        return ;
    }
    
    MarkdownModel *paraModel = [editor cleanMarkOfParagraph] ;
    tmpString = [editor.text mutableCopy] ;
    // add
    if (!paraModel) {
        [tmpString insertString:@"$$\n \n$$" atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        id modelParse = [editor.parser modelForModelListBlockFirst] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 3, 0) ;
        [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
        return ;
    }
    
    // replace
    if (paraModel.type == MarkdownSyntaxMultipleMath) return ;
    
    [tmpString insertString:@"\n$$" atIndex:paraModel.range.location + paraModel.range.length] ;
    [tmpString insertString:@"$$\n" atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
    MarkdownModel *modelParse = [editor.parser modelForModelListBlockFirst] ;
    [editor doSomethingWhenUserSelectPartOfArticle:modelParse] ;
    editor.selectedRange = NSMakeRange(modelParse.range.length + modelParse.range.location, 0) ;

}



@end
