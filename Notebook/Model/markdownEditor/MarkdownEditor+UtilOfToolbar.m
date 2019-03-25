//
//  MarkdownEditor+UtilOfToolbar.m
//  Notebook
//
//  Created by teason23 on 2019/3/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor+UtilOfToolbar.h"


@implementation MarkdownEditor (UtilOfToolbar)

- (MarkdownModel *)cleanMarkOfParagraph {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    NSInteger position = self.selectedRange.location ;
    MarkdownModel *paraModel ;
    while (paraModel == nil) {
        paraModel = [self.markdownPaser paraModelForPosition:position] ;
        position -- ;
    }
    
    MarkdownModel *blkModel = [self.markdownPaser parsingGetABlockStyleModelFromParaModel:paraModel] ;
    if (blkModel) {
        NSString *tmpPrefixStr = blkModel.str ;
        if (blkModel.type == MarkdownSyntaxTaskLists) {
            tmpPrefixStr = [[tmpPrefixStr componentsSeparatedByString:@"]"] firstObject] ;
            [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location, tmpPrefixStr.length + 2)] ;
            blkModel.range = NSMakeRange(blkModel.range.location, blkModel.range.length - (tmpPrefixStr.length + 2)) ;
        }
        else if (blkModel.type == MarkdownSyntaxCodeBlock) {
            [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location + blkModel.range.length - 4, 4)] ;
            tmpPrefixStr = [[tmpPrefixStr componentsSeparatedByString:@"\n"] firstObject] ;
            [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location, tmpPrefixStr.length + 1)] ;
            blkModel.range = NSMakeRange(blkModel.range.location, blkModel.range.length - (tmpPrefixStr.length + 1 + 4)) ;
        }
        else {
            tmpPrefixStr = [[tmpPrefixStr componentsSeparatedByString:@" "] firstObject] ;
            [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location, tmpPrefixStr.length + 1)] ;
            blkModel.range = NSMakeRange(blkModel.range.location, blkModel.range.length - (tmpPrefixStr.length + 1)) ;
        }
        [self.markdownPaser parseText:tmpString position:blkModel.range.location textView:self] ;
    }
    else {
        blkModel = paraModel ;
//        self.selectedRange = NSMakeRange(paraModel.range.location, 0) ; // 必须在操作之后再加selectionRange
    }
    [self doSomethingWhenUserSelectPartOfArticle] ;
    
    return blkModel ;
}

#pragma mark - MDToolbarDelegate <NSObject>

- (void)makeHeaderWithSize:(NSString *)mark {
    MarkdownModel *paraModel = [self cleanMarkOfParagraph] ;
    if (!paraModel) return ;
    
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:mark atIndex:paraModel.range.location] ;
    [self.markdownPaser parseText:tmpString position:paraModel.range.location textView:self] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectRemoveTitle {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *paraModel = [self.markdownPaser paraModelForPosition:self.selectedRange.location] ;
    if ([paraModel.str hasPrefix:@"#"]) {
        NSString *prefix = [[paraModel.str componentsSeparatedByString:@" "] firstObject] ;
        NSInteger delNum = prefix.length + 1 ;
        [tmpString deleteCharactersInRange:NSMakeRange(paraModel.range.location, delNum)] ;
    }
    [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
}
- (void)toolbarDidSelectH1 {
    [self makeHeaderWithSize:@"# "] ;
}
- (void)toolbarDidSelectH2 {
    [self makeHeaderWithSize:@"## "] ;
}
- (void)toolbarDidSelectH3 {
    [self makeHeaderWithSize:@"### "] ;
}
- (void)toolbarDidSelectH4 {
    [self makeHeaderWithSize:@"#### "] ;
}
- (void)toolbarDidSelectH5 {
    [self makeHeaderWithSize:@"##### "] ;
}
- (void)toolbarDidSelectH6 {
    [self makeHeaderWithSize:@"###### "] ;
}
- (void)toolbarDidSelectSepLine {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"\n---\n" atIndex:self.selectedRange.location] ;
    [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    self.selectedRange = NSMakeRange(self.selectedRange.location + 5, 0) ;
}


- (void)toolbarDidSelectBold {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    // del
    if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        return ;
    }
    
    if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        [self toolbarDidSelectItalic] ;
        return ;
    }
    
    if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        self.selectedRange = NSMakeRange(model.range.location + 1, numOfStr) ;
    }
    
    // add
    if (!self.selectedRange.length) {
        [tmpString insertString:@"****" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, 0) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else {
        [tmpString insertString:@"**" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"**" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, self.selectedRange.length) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectItalic {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    // del
    if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 1 + numOfStr, 1)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 1)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        return ;
    }
    
    if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        [self toolbarDidSelectBold] ;
        return ;
    }
    
    if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        self.selectedRange = NSMakeRange(model.range.location + 2, numOfStr) ;
    }
    
    // add
    if (!self.selectedRange.length) {
        [tmpString insertString:@"**" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 1, 0) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else {
        [tmpString insertString:@"*" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"*" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 1, self.selectedRange.length) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectDeletion {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    // del
    if (model.type == MarkdownInlineDeletions) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location - 2, numOfStr) ;
        return ;
    }
    
    if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 1 + numOfStr, 1)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 1)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    
    // add
    if (!self.selectedRange.length) {
        [tmpString insertString:@"~~~~" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, 0) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    else { // todo
        [tmpString insertString:@"~~" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"~~" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, self.selectedRange.length) ;
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }
    
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectInlineCode {
    
}

- (void)toolbarDidSelectPhoto {
    
}

- (void)toolbarDidSelectLink {
    MarkdownModel *model = [self.markdownPaser modelForRangePosition:self.selectedRange.location] ;
    
    @weakify(self)
    [MDEditUrlView showOnView:self window:self.window model:model keyboardHeight:keyboardHeight callback:^(BOOL isConfirm, NSString *title, NSString *url) {
        @strongify(self)
        NSMutableString *tmpString = [self.text mutableCopy] ;
        NSString *linkStr = STR_FORMAT(@"[%@](%@)",title,url) ;
        if (model && model.type == MarkdownInlineLinks) {
            [tmpString deleteCharactersInRange:model.range] ;
            [tmpString insertString:linkStr atIndex:model.range.location] ;
        }
        else {
            [tmpString insertString:linkStr atIndex:self.selectedRange.location] ;
        }
        [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    }] ;
}

- (void)toolbarDidSelectUList {
    MarkdownModel *paraModel = [self cleanMarkOfParagraph] ;
    if (paraModel.type == MarkdownSyntaxULLists) return ;
    if (!paraModel) return ;
    
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"* " atIndex:paraModel.range.location] ;
    [self.markdownPaser parseText:tmpString position:paraModel.range.location textView:self] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
}
- (void)toolbarDidSelectOrderlist {
    
}
- (void)toolbarDidSelectTaskList {
    MarkdownModel *paraModel = [self cleanMarkOfParagraph] ;
    if (paraModel.type == MarkdownSyntaxTaskLists) return ;
    if (!paraModel) return ;
    
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"* [ ] " atIndex:paraModel.range.location] ;
    [self.markdownPaser parseText:tmpString position:paraModel.range.location textView:self] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectCodeBlock {
    MarkdownModel *paraModel = [self cleanMarkOfParagraph] ;
    if (paraModel.type == MarkdownSyntaxCodeBlock) return ;
    if (!paraModel) return ;

    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"\n```" atIndex:paraModel.range.location + paraModel.range.length] ;
    [tmpString insertString:@"```\n" atIndex:paraModel.range.location] ;
//    self.selectedRange = NSMakeRange(paraModel.range.location, 0) ;
    [self.markdownPaser parseText:tmpString position:self.selectedRange.location textView:self] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectQuoteBlock {
    MarkdownModel *paraModel = [self cleanMarkOfParagraph] ;
    if (paraModel.type == MarkdownSyntaxBlockquotes) return ;
    if (!paraModel) return ;
    
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"> " atIndex:paraModel.range.location] ;
    [self.markdownPaser parseText:tmpString position:paraModel.range.location textView:self] ;
    [self doSomethingWhenUserSelectPartOfArticle] ;
}

- (void)toolbarDidSelectUndo {
    [[self undoManager] undo];
}
- (void)toolbarDidSelectRedo {
    [[self undoManager] redo];
}

@end
