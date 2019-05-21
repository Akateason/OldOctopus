//
//  MarkdownEditor+InlineBoardUtil.m
//  Notebook
//
//  Created by teason23 on 2019/5/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor+InlineBoardUtil.h"
#import "MDEditUrlView.h"
#import "MDHeadModel.h"
#import "MdListModel.h"
#import "MdBlockModel.h"
#import "MdInlineModel.h"
#import "MDEKeyboardPhotoView.h"
#import "MDImageManager.h"
#import "XTMarkdownParser+Fetcher.h"
#import "MdInlineModel.h"
#import "MarkdownEditor+OctToolbarUtil.h"

@implementation MarkdownEditor (InlineBoardUtil)

//@protocol OctToolBarInlineViewDelegate <NSObject>

- (void)toolbarDidSelectClearToCleanPara {
    MarkdownModel *model = [self cleanMarkOfParagraph] ;
    self.selectedRange = NSMakeRange(model.range.location + model.range.length, 0) ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}
- (void)toolbarDidSelectH1 {
    [MDHeadModel makeHeaderWithSize:@"# " editor:self] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}
- (void)toolbarDidSelectH2 {
    [MDHeadModel makeHeaderWithSize:@"## " editor:self] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}
- (void)toolbarDidSelectH3 {
    [MDHeadModel makeHeaderWithSize:@"### " editor:self] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}
- (void)toolbarDidSelectH4 {
    [MDHeadModel makeHeaderWithSize:@"#### " editor:self] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}
- (void)toolbarDidSelectH5 {
    [MDHeadModel makeHeaderWithSize:@"##### " editor:self] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}
- (void)toolbarDidSelectH6 {
    [MDHeadModel makeHeaderWithSize:@"###### " editor:self] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}





- (void)toolbarDidSelectBold {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.parser modelForModelListInlineFirst] ;
    // del
    if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 2 + numOfStr, 2)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 2)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        [self doSomethingWhenUserSelectPartOfArticle:nil] ;
        return ;
    }
    else if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        [self toolbarDidSelectItalic] ;
        return ;
    }
    else if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        self.selectedRange = NSMakeRange(model.range.location + 1, numOfStr) ;
    }
    else {
        tmpString = [MdInlineModel clearAllInlineMark:self model:model] ;
        model = [self.parser modelForModelListInlineFirst] ;
    }
    
    // add
    id modelAdded ;
    if (!self.selectedRange.length) {
        [tmpString insertString:@"****" atIndex:self.selectedRange.location] ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        modelAdded = [self.parser modelForModelListInlineFirst] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, 0) ;
    }
    else {
        [tmpString insertString:@"**" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"**" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 2, self.selectedRange.length) ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        modelAdded = [self.parser modelForModelListInlineFirst] ;
    }
    [self doSomethingWhenUserSelectPartOfArticle:modelAdded] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}

- (void)toolbarDidSelectItalic {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *model = [self.parser modelForModelListInlineFirst] ;
    // del
    if (model.type == MarkdownInlineItalic) {
        NSInteger numOfStr = model.str.length - 2 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 1 + numOfStr, 1)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 1)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        [self doSomethingWhenUserSelectPartOfArticle:nil] ;
        return ;
    }
    else if (model.type == MarkdownInlineBoldItalic) {
        NSInteger numOfStr = model.str.length - 6 ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location + 3 + numOfStr, 3)] ;
        [tmpString deleteCharactersInRange:NSMakeRange(model.range.location, 3)] ;
        self.selectedRange = NSMakeRange(model.range.location, numOfStr) ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        [self toolbarDidSelectBold] ;
        return ;
    }
    else if (model.type == MarkdownInlineBold) {
        NSInteger numOfStr = model.str.length - 4 ;
        self.selectedRange = NSMakeRange(model.range.location + 2, numOfStr) ;
    }
    else {
        tmpString = [MdInlineModel clearAllInlineMark:self model:model] ;
        model = [self.parser modelForModelListInlineFirst] ;
    }
    
    // add
    id modelAdded ;
    if (!self.selectedRange.length) {
        [tmpString insertString:@"**" atIndex:self.selectedRange.location] ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        modelAdded = [self.parser modelForModelListInlineFirst] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 1, 0) ;
    }
    else {
        [tmpString insertString:@"*" atIndex:self.selectedRange.location + self.selectedRange.length] ;
        [tmpString insertString:@"*" atIndex:self.selectedRange.location] ;
        self.selectedRange = NSMakeRange(self.selectedRange.location + 1, self.selectedRange.length) ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        modelAdded = [self.parser modelForModelListInlineFirst] ;
    }
    
    [self doSomethingWhenUserSelectPartOfArticle:modelAdded] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}

- (void)toolbarDidSelectDeletion {
    [MdInlineModel toolbarEventDeletion:self] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}

- (void)toolbarDidSelectInlineCode {
    [MdInlineModel toolbarEventCode:self] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
}

@end
