//
//  MarkdownModel.m
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownModel.h"
#import <XTlib/XTlib.h>
#import "XTMarkdownParser.h"
#import "MarkdownEditor.h"

@implementation MarkdownModel

- (instancetype)initWithType:(int)type range:(NSRange)range str:(NSString *)str {
    return [self initWithType:type range:range str:str level:0] ;
}

- (instancetype)initWithType:(int)type range:(NSRange)range str:(NSString *)str level:(int)level {
    self = [super init] ;
    if (self) {
        _type               = type ;
        _range              = range ;
        _str                = str ;
        _quoteAndList_Level = level ;
    }
    return self;
}

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str {
    return [[self alloc] initWithType:type range:range str:str level:0] ;
}

+ (instancetype)modelWithType:(int)type range:(NSRange)range str:(NSString *)str level:(int)level {
    MarkdownModel *model = [[self alloc] initWithType:type range:range str:str level:level] ;
    [model textIndentationPosition] ;
    [model markIndentationPosition] ;
    return model ;
}

- (int)textIndentationPosition {
    _textIndentationPosition = 0 ;
    MarkdownModel *tmpModel = self ;
    while ( tmpModel.subBlkModel
           &&
            (tmpModel.subBlkModel.type == MarkdownSyntaxBlockquotes ||
             tmpModel.subBlkModel.type == MarkdownSyntaxULLists ||
             tmpModel.subBlkModel.type == MarkdownSyntaxOLLists
             ) ) {
                
            _textIndentationPosition ++ ;
            tmpModel = tmpModel.subBlkModel ;
    }
    return _textIndentationPosition ;
}

- (int)markIndentationPosition {
    _markIndentationPosition = _quoteAndList_Level ;
    return _markIndentationPosition ;
}

- (int)wholeNestCountForquoteAndList {
    return self.textIndentationPosition ;
}

- (CGFloat)valueOfparaBeginEndSpaceOffset {
    switch (self.paraBeginEndSpaceOffset) {
        case 0: return 0 ;
//        case 1: return kDefaultFontSize * 1.3 ;
        case 1: return kDefaultFontSize * 1.3 - (kDefaultFontSize + 10) ;
//        case 2: return kDefaultFontSize * 2. ;
        case 2: return kDefaultFontSize * 2. - (kDefaultFontSize + 10) ;
    }
    return 0 ;
}


- (NSString *)displayStringForLeftLabel {
    return @"" ;
}

- (NSUInteger)location {
    return self.range.location ;
}

- (NSUInteger)length {
    return self.range.length ;
}

- (UIFont *)defaultFont {
    return [MDThemeConfiguration sharedInstance].editorThemeObj.font ;
}

- (NSDictionary *)defultStyle {
    return MDThemeConfiguration.sharedInstance.editorThemeObj.basicStyle ;
}

- (NSMutableAttributedString *)addAttrOnPreviewState:(NSMutableAttributedString *)attributedString
                                              {
    if (self.type == -1) { // paragraph
        [attributedString addAttributes:[MDEditorTheme basicStyleWithParaSpacing:self.valueOfparaBeginEndSpaceOffset] range:self.range] ;
    }
    
    return attributedString ;
}

- (NSMutableAttributedString *)addAttrOnEditState:(NSMutableAttributedString *)attributedString
                                         position:(NSUInteger)tvPosition {
    
    if (self.type == -1) { // paragraph
        [attributedString addAttributes:[MDEditorTheme basicStyleWithParaSpacing:self.valueOfparaBeginEndSpaceOffset] range:self.range] ;
    }

    return attributedString ;
}

- (id)copyWithZone:(NSZone *)zone {
    MarkdownModel *p = [[MarkdownModel allocWithZone:zone] init] ;
    p.range = self.range ;
    p.type = self.type ;
    p.str = [self.str mutableCopy] ;
    p.isOnEditState = self.isOnEditState ;
    p.inlineModels = [self.inlineModels mutableCopy] ;
    p.quoteAndList_Level = _quoteAndList_Level ;
    p.textIndentationPosition = _textIndentationPosition ;
    p.markIndentationPosition = _markIndentationPosition ;
    p.subBlkModel = self.subBlkModel ;
    return p ;
}


+ (int)keyboardEnterTypedInTextView:(MarkdownEditor *)textView
                    modelInPosition:(MarkdownModel *)aModel
            shouldChangeTextInRange:(NSRange)range {
    
    NSMutableString *tmpString = [textView.text mutableCopy] ;
    NSString *insertEnterString = @"\n\n" ;
    
    if (aModel.type == -1) {
        [tmpString insertString:insertEnterString atIndex:range.location] ;
        [textView.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:range.location textView:textView] ;
        textView.selectedRange = NSMakeRange(range.location + insertEnterString.length, 0) ;
        return NO ;
    }
    return 100 ; // 未知情况, 传到下一个model去处理
}



@end
