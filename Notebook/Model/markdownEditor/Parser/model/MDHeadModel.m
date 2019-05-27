//
//  MDHeadModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDHeadModel.h"
#import "MarkdownEditor.h"
#import "MarkdownEditor+OctToolbarUtil.h"
#import "XTMarkdownParser+Fetcher.h"

@implementation MDHeadModel

+ (instancetype)modelWithType:(int)type
                        range:(NSRange)range
                          str:(NSString *)str {
    MDHeadModel *model = [super modelWithType:type range:range str:str] ;
    BOOL valid = [str containsString:@" "] && [[[str componentsSeparatedByString:@" "] firstObject] hasSuffix:@"#"] ;
    return (!valid) ? nil : model ;
}

- (NSString *)displayStringForLeftLabel {
    NSString *str = [super displayStringForLeftLabel] ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [[self.str componentsSeparatedByString:@" "] firstObject] ;
            NSUInteger numberOfmark = [prefix xt_searchAllRangesWithText:@"#"].count ;
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

- (UIFont *)fontWithHSize:(NSUInteger)numberOfmark {
    UIFont *font = [UIFont systemFontOfSize:kDefaultFontSize] ;
    switch (numberOfmark) {
        case 1: font = [UIFont boldSystemFontOfSize:kSizeH1]; break;
        case 2: font = [UIFont boldSystemFontOfSize:kSizeH2]; break;
        case 3: font = [UIFont boldSystemFontOfSize:kSizeH3]; break;
        case 4: font = [UIFont boldSystemFontOfSize:kSizeH4]; break;
        case 5: font = [UIFont boldSystemFontOfSize:kSizeH5]; break;
        case 6: font = [UIFont boldSystemFontOfSize:kSizeH6]; break;
        default: break;
    }
    return font ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString {

    NSDictionary *resultDic = MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [self prefixOfTitle] ;
            NSUInteger numberOfmark = prefix.length ;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.paragraphSpacing = self.valueOfparaBeginEndSpaceOffset ;
            UIFont *hFont = [self fontWithHSize:numberOfmark] ;
            resultDic = @{NSFontAttributeName : hFont ,
                          NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .8),
                          NSParagraphStyleAttributeName : paragraphStyle
                                      } ;
            [attributedString addAttributes:resultDic range:self.range] ;
            
            // hide "# " marks
            NSRange markRange = NSMakeRange(location, numberOfmark + 1) ;
            if (numberOfmark + 1 > length) return attributedString ;
            
            
            NSMutableDictionary *tmpdic = [MDThemeConfiguration.sharedInstance.editorThemeObj.invisibleMarkStyle mutableCopy] ;
            [tmpdic setValue:paragraphStyle forKey:NSParagraphStyleAttributeName] ;
            [attributedString addAttributes:tmpdic range:markRange] ;
        }
            break;
            
        default:
            break;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    NSDictionary *resultDic = MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
    NSUInteger location = self.range.location ;
    NSUInteger length = self.range.length ;
    
    switch (self.type) {
        case MarkdownSyntaxHeaders: {
            NSString *prefix = [self prefixOfTitle] ;
            NSUInteger numberOfmark = prefix.length ;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.paragraphSpacing = self.valueOfparaBeginEndSpaceOffset ;
            UIFont *hFont = [self fontWithHSize:numberOfmark] ;
            resultDic = @{NSFontAttributeName : hFont ,
                          NSForegroundColorAttributeName : XT_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) ,
                          NSParagraphStyleAttributeName : paragraphStyle
                          } ;
            [attributedString addAttributes:resultDic range:self.range] ;
            
            if (tvPosition > location + numberOfmark + 1) {
                // hide "# " marks
                NSRange markRange = NSMakeRange(location, numberOfmark + 1) ;
                if (numberOfmark + 1 > length) return attributedString ;
                
                NSMutableDictionary *tmpdic = [MDThemeConfiguration.sharedInstance.editorThemeObj.invisibleMarkStyle mutableCopy] ;
                [tmpdic setValue:paragraphStyle forKey:NSParagraphStyleAttributeName] ;
                [attributedString addAttributes:tmpdic range:markRange] ;
            }
            else {
                NSMutableDictionary *tmpdic = [MDThemeConfiguration.sharedInstance.editorThemeObj.markStyle mutableCopy] ;
                NSRange markRange = NSMakeRange(location, numberOfmark) ;
                [tmpdic setValue:paragraphStyle forKey:NSParagraphStyleAttributeName] ;
                [attributedString addAttributes:tmpdic range:markRange] ;
            }
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
        [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:editor.selectedRange.location + mark.length textView:editor] ;
        editor.selectedRange = NSMakeRange(editor.selectedRange.location + mark.length, 0) ;
        return ;
    }
    
    // replace
    [tmpString insertString:mark atIndex:paraModel.range.location] ;
    [editor.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:paraModel.range.location textView:editor] ;
    MarkdownModel *model = [editor.parser modelForModelListBlockFirst] ;
    editor.selectedRange = NSMakeRange(model.range.length + model.range.location, 0) ;
    [editor doSomethingWhenUserSelectPartOfArticle:model] ;
}



+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range {
    
    NSMutableString *tmpString = [textView.text mutableCopy] ;
    NSString *insertEnterString = @"\n\n" ;
    
    if (aModel.type == MarkdownSyntaxHeaders) {
        [tmpString insertString:insertEnterString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertEnterString.length, 0) ;
        return NO ;
    }
    return 100 ; // 未知情况, 传到下一个model去处理
}

@end
