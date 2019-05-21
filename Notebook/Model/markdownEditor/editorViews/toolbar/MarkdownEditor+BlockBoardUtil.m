//
//  MarkdownEditor+BlockBoardUtil.m
//  Notebook
//
//  Created by teason23 on 2019/5/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor+BlockBoardUtil.h"
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

@implementation MarkdownEditor (BlockBoardUtil)

- (void)toolbarDidSelectLeftTab {
    MarkdownModel *model = [self.parser modelForModelListBlockFirst] ;
    if (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists) {
        MdListModel *listModel = (MdListModel *)model ;
        if (listModel.countForSpace >= 2) {
            NSMutableString *tmpString = [self.text mutableCopy] ;
            [tmpString deleteCharactersInRange:NSMakeRange(model.location, 2)] ;
            [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ; // notificate for update .
        }
    }
}

- (void)toolbarDidSelectRightTab {
    MarkdownModel *model = [self.parser modelForModelListBlockFirst] ;
    if (model.type == MarkdownSyntaxOLLists || model.type == MarkdownSyntaxULLists) {
//        MdListModel *listModel = (MdListModel *)model ;
        NSMutableString *tmpString = [self.text mutableCopy] ;
        [tmpString insertString:@"  " atIndex:model.location] ;
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ; // notificate for update .
    }
}

- (void)toolbarDidSelectSepLine {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"\n\n---\n\n" atIndex:self.selectedRange.location] ;
    [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
    self.selectedRange = NSMakeRange(self.selectedRange.location + 6, 0) ;
}

- (void)toolbarDidSelectLink {
    MarkdownModel *model = [self.parser modelForModelListInlineFirst] ;
    @weakify(self)
    [MDEditUrlView showOnView:self window:self.window model:model keyboardHeight:keyboardHeight callback:^(BOOL isConfirm, NSString *title, NSString *url) {
        @strongify(self)
        if (!isConfirm) {
            [self becomeFirstResponder] ;
            return ;
        }
        
        NSMutableString *tmpString = [self.text mutableCopy] ;
        NSString *linkStr = STR_FORMAT(@"[%@](%@)",title,url) ;
        if (model && model.type == MarkdownInlineLinks) {
            [tmpString deleteCharactersInRange:model.range] ;
            [tmpString insertString:linkStr atIndex:model.range.location] ;
        }
        else {
            [tmpString insertString:linkStr atIndex:self.selectedRange.location] ;
        }
        [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ; // notificate for update .
    }] ;
}

- (void)toolbarDidSelectUList {
    [MdListModel toolbarEventForUlist:self] ;
}

- (void)toolbarDidSelectOrderlist {
    [MdListModel toolbarEventForOrderList:self] ;
}

- (void)toolbarDidSelectTaskList {
    [MdListModel toolbarEventForTasklist:self] ;
}

- (void)toolbarDidSelectCodeBlock {
    [MdBlockModel toolbarEventCodeBlock:self] ;
}

- (void)toolbarDidSelectQuoteBlock {
    [MdBlockModel toolbarEventQuoteBlock:self] ;
}

@end
