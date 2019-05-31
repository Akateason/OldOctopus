//
//  MdInlineModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MdInlineModel.h"
#import <XTlib/XTlib.h>
#import "MarkdownEditor.h"
#import "MarkdownEditor+OctToolbarUtil.h"
#import "XTMarkdownParser+Fetcher.h"

@implementation MdInlineModel

- (NSString *)displayStringForLeftLabel {
    
    NSString *str = [super displayStringForLeftLabel] ;
    switch (self.type) {
        case MarkdownInlineBold: str = @"md_tb_bt_bold" ; break ;
        case MarkdownInlineItalic: str = @"md_tb_bt_italic" ; break ;
        case MarkdownInlineBoldItalic: str = @"md_tb_bt_bold" ; break ;
        case MarkdownInlineDeletions: str = @"md_tb_bt_deletion" ; break ;
        case MarkdownInlineInlineCode: str = @"md_tb_bt_code" ; break ;
        case MarkdownInlineLinks: str = @"md_tb_bt_link" ; break ;
//        case MarkdownInlineImage: str = @"image" ; break ;
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
        case MarkdownInlineBold: {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            [resultDic setObject:configuration.editorThemeObj.boldFont forKey:NSFontAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineItalic: {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            [resultDic setObject:configuration.editorThemeObj.italicFont forKey:NSFontAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownInlineBoldItalic: {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location + length - 3, 3)] ;
            
            [resultDic setObject:configuration.editorThemeObj.boldItalicFont forKey:NSFontAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownInlineDeletions: {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            [resultDic setObject:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName] ;
            [resultDic setObject:paragraphFont forKey:NSFontAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineInlineCode: {
            if (self.str.length == 2) return attributedString ;
            
            resultDic = [configuration.editorThemeObj.invisibleMarkStyle mutableCopy] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = [resultDic mutableCopy] ;
            [resultDic setValue:@(configuration.editorThemeObj.inlineCodeSideFlex) forKey:NSKernAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 1)] ;
            
            resultDic = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .75),
                          NSFontAttributeName : paragraphFont ,
                          } ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
            resultDic = [resultDic mutableCopy] ;
            [resultDic setValue:@(configuration.editorThemeObj.inlineCodeSideFlex) forKey:NSKernAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + length - 2, 1)] ;
        }
            break ;
        case MarkdownInlineLinks: {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:self.range] ;
            resultDic = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_linkColor),
                          NSFontAttributeName : paragraphFont,
                          NSUnderlineStyleAttributeName : @1
                          };
            NSString *prefixAddFKH = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
            NSRange tmpRange = NSMakeRange(location + 1, prefixAddFKH.length - 1) ;
            [attributedString addAttributes:resultDic range:tmpRange] ;
        }
            break ;
        case MarkdownInlineImage : {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:self.range] ;
        }
            break ;
        case MarkdownInlineEscape : {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 1)] ;
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
        case MarkdownInlineBold: {
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSFontAttributeName : configuration.editorThemeObj.boldFont} ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineItalic: {
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location + length - 1, 1)] ;
            
            resultDic = @{NSFontAttributeName : configuration.editorThemeObj.italicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
        }
            break ;
        case MarkdownInlineBoldItalic: {
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location, 3)] ;
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location + length - 3, 3)] ;
            
            resultDic = @{NSFontAttributeName : configuration.editorThemeObj.boldItalicFont};
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 3, length - 6)] ;
        }
            break ;
        case MarkdownInlineDeletions: {
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location, 2)] ;
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location + length - 2, 2)] ;
            
            resultDic = @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSFontAttributeName : paragraphFont
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 2, length - 4)] ;
        }
            break ;
        case MarkdownInlineInlineCode: {
            if (self.str.length == 2) return attributedString ;
            
            resultDic = [configuration.editorThemeObj.markStyle mutableCopy] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + length - 1, 1)] ;

            resultDic = [resultDic mutableCopy] ;
            [resultDic setValue:@(configuration.editorThemeObj.inlineCodeSideFlex) forKey:NSKernAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location, 1)] ;
            
            resultDic = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .75) ,
                          NSFontAttributeName : paragraphFont,
                          };
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 2)] ;
            
            resultDic = [resultDic mutableCopy] ;
            [resultDic setValue:@(configuration.editorThemeObj.inlineCodeSideFlex) forKey:NSKernAttributeName] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + length - 2, 1)] ;
        }
            break ;
        case MarkdownInlineLinks: {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:self.range] ;
            resultDic = @{NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY(k_md_linkColor),
                          NSFontAttributeName : paragraphFont,
                          NSUnderlineStyleAttributeName : @1
                          };
            NSString *prefixAddFKH = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
            NSRange tmpRange = NSMakeRange(location + 1, prefixAddFKH.length - 1) ;
            [attributedString addAttributes:resultDic range:tmpRange] ;
        }
            break ;
        case MarkdownInlineImage : {
            [attributedString addAttributes:configuration.editorThemeObj.invisibleMarkStyle range:self.range] ;
        }
            break ;
        case MarkdownInlineEscape : {
            [attributedString addAttributes:configuration.editorThemeObj.markStyle range:NSMakeRange(location, 1)] ;
            [attributedString addAttributes:resultDic range:NSMakeRange(location + 1, length - 1)] ;
        }
            break ;

        default:
            break;
    }
    
    return attributedString ;
}








- (NSString *)imageUrl {
    if (self.type != MarkdownInlineImage) return nil ;
        
    NSRange startRange = [self.str rangeOfString:@"("];
    NSRange endRange = [self.str rangeOfString:@")"];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length) ;
    NSString *result = [self.str substringWithRange:range];
    return result ;
}

- (NSString *)linkTitle {
    if (self.type != MarkdownInlineLinks) return nil ;
    
    NSString *str = [[self.str componentsSeparatedByString:@"]"] firstObject] ;
    return [str substringFromIndex:1] ;
}

- (NSString *)linkUrl {
    if (self.type != MarkdownInlineLinks) return nil ;
    
    NSString *str = [[self.str componentsSeparatedByString:@"("] lastObject] ;
    return [str substringToIndex:str.length - 1] ;
}







+ (NSMutableString *)clearAllInlineMark:(MarkdownEditor *)editor model:(MarkdownModel *)model {
    NSMutableString *tmpString = [editor.text mutableCopy] ;
    if (model.type == MarkdownInlineDeletions) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location - 2, numOfStr) ;
    }
    else if (model.type == MarkdownInlineInlineCode) {
        NSInteger numOfStr = model.str.length - 2 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 1 + numOfStr, 1)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 1)] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location - 1, numOfStr) ;
    }
    else if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        editor.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
    }
    else if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 1 + numOfStr, 1)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 1)] ;
        editor.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
    }
    else if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        editor.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
    }
    [editor doSomethingWhenUserSelectPartOfArticle:nil] ;
    return tmpString ;
}

+ (void)toolbarEventDeletion:(MarkdownEditor *)editor {
    MdInlineModel *model = (MdInlineModel *)[editor.parser modelForModelListInlineFirst] ;
    NSMutableString *tmpString = [self clearAllInlineMark:editor model:model] ;
    if (!model) tmpString = [editor.text mutableCopy] ;
    
    // del
    if (model.type == MarkdownInlineDeletions) return ;
    
    // add
    id modelAdded ;
    if (!editor.selectedRange.length) {
        [tmpString insertString:@"~~~~" atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        modelAdded = [editor.parser modelForModelListInlineFirst] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 2, 0) ;
    }
    else {
        [tmpString insertString:@"~~" atIndex:editor.selectedRange.location + editor.selectedRange.length] ;
        [tmpString insertString:@"~~" atIndex:editor.selectedRange.location] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 2, editor.selectedRange.length) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        modelAdded = [editor.parser modelForModelListInlineFirst] ;
    }
    [editor doSomethingWhenUserSelectPartOfArticle:modelAdded] ;
}

+ (void)toolbarEventCode:(MarkdownEditor *)editor {
    MdInlineModel *model = (MdInlineModel *)[editor.parser modelForModelListInlineFirst] ;
    NSMutableString *tmpString = [self clearAllInlineMark:editor model:model] ;
    if (!model) tmpString = [editor.text mutableCopy] ;
    
    // del
    if (model.type == MarkdownInlineInlineCode) return ;
    
    // add
    id modelAdded ;
    if (!editor.selectedRange.length) {
        [tmpString insertString:@"``" atIndex:editor.selectedRange.location] ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        modelAdded = [editor.parser modelForModelListInlineFirst] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 1, 0) ;
    }
    else {
        [tmpString insertString:@"`" atIndex:editor.selectedRange.location + editor.selectedRange.length] ;
        [tmpString insertString:@"`" atIndex:editor.selectedRange.location] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + 1, editor.selectedRange.length) ;
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:editor] ;
        modelAdded = [editor.parser modelForModelListInlineFirst] ;
    }
    [editor doSomethingWhenUserSelectPartOfArticle:modelAdded] ;
}


// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.range = NSMakeRange([dic[@"location"] intValue], [dic[@"length"] intValue]) ;
    return YES;
}


@end
