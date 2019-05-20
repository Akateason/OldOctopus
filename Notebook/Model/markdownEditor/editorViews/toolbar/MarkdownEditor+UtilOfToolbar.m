//
//  MarkdownEditor+UtilOfToolbar.m
//  Notebook
//
//  Created by teason23 on 2019/3/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor+UtilOfToolbar.h"
#import "MDEditUrlView.h"
#import "MDHeadModel.h"
#import "MdListModel.h"
#import "MdBlockModel.h"
#import "MdInlineModel.h"
#import "MDEKeyboardPhotoView.h"
#import "MDImageManager.h"
#import <XTlib/XTlib.h>
#import "XTMarkdownParser+Fetcher.h"
#import "MdInlineModel.h"

@implementation MarkdownEditor (UtilOfToolbar)

ASSOCIATED(photoView, setPhotoView, MDEKeyboardPhotoView *, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;

- (MarkdownModel *)cleanMarkOfParagraph {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    MarkdownModel *blkModel = [self.parser modelForModelListBlockFirst] ;
    if (!blkModel) return nil ;
    if (blkModel.type == -1) return blkModel ; // return pure para .
    
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
    else if (blkModel.type != -1) {
        tmpPrefixStr = [[tmpPrefixStr componentsSeparatedByString:@" "] firstObject] ;
        [tmpString deleteCharactersInRange:NSMakeRange(blkModel.range.location, tmpPrefixStr.length + 1)] ;
        blkModel.range = NSMakeRange(blkModel.range.location, blkModel.range.length - (tmpPrefixStr.length + 1)) ;
    }
    [self.parser parseTextAndGetModelsInCurrentCursor:tmpString customPosition:blkModel.range.location textView:self] ;
    self.selectedRange = NSMakeRange(blkModel.range.location + blkModel.range.length, 0) ;
    [self doSomethingWhenUserSelectPartOfArticle:nil] ;
    
    return blkModel ;
}

- (MarkdownModel *)lastOneParagraphMarkdownModel {
    return [self lastOneParagraphMarkdownModelWithPosition:self.selectedRange.location] ;
}

- (MarkdownModel *)lastOneParagraphMarkdownModelWithPosition:(NSUInteger)position {
    MarkdownModel *lastParaModel = [self.parser lastParaModelForPosition:position] ;
    if (!lastParaModel) return nil ;
    
    return lastParaModel ;
}

#pragma mark - MDToolbarDelegate <NSObject>

- (void)toolbarDidSelectRemoveTitle {
    MarkdownModel *model = [self cleanMarkOfParagraph] ;
    self.selectedRange = NSMakeRange(model.range.location + model.range.length, 0) ;
}
- (void)toolbarDidSelectH1 {
    [MDHeadModel makeHeaderWithSize:@"# " editor:self] ;
}
- (void)toolbarDidSelectH2 {
    [MDHeadModel makeHeaderWithSize:@"## " editor:self] ;
}
- (void)toolbarDidSelectH3 {
    [MDHeadModel makeHeaderWithSize:@"### " editor:self] ;
}
- (void)toolbarDidSelectH4 {
    [MDHeadModel makeHeaderWithSize:@"#### " editor:self] ;
}
- (void)toolbarDidSelectH5 {
    [MDHeadModel makeHeaderWithSize:@"##### " editor:self] ;
}
- (void)toolbarDidSelectH6 {
    [MDHeadModel makeHeaderWithSize:@"###### " editor:self] ;
}
- (void)toolbarDidSelectSepLine {
    NSMutableString *tmpString = [self.text mutableCopy] ;
    [tmpString insertString:@"\n---\n\n" atIndex:self.selectedRange.location] ;
    [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
    self.selectedRange = NSMakeRange(self.selectedRange.location + 6, 0) ;
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
}

- (void)toolbarDidSelectDeletion {
    [MdInlineModel toolbarEventDeletion:self] ;
}

- (void)toolbarDidSelectInlineCode {
    [MdInlineModel toolbarEventCode:self] ;
}

- (void)toolbarDidSelectPhoto {
    @weakify(self)
    self.photoView =
    [MDEKeyboardPhotoView showViewFromCtrller:self.xt_viewController kbheight:keyboardHeight WhenUserPressedPhotoOnList:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self uploadImage:image] ;
        self.photoView = nil ;
    } cameraOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self uploadImage:image] ;
        self.photoView = nil ;
    } albumOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self uploadImage:image] ;
        self.photoView = nil ;
    } cancel:^{
        self.photoView = nil ;
    }] ;
}

- (void)uploadImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @weakify(self)
        [self.parser.imgManager uploadImage:image progress:^(float pgs) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:pgs status:@"正在上传图片"]  ;
            }) ;
        } success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss] ;
                
                NSString *url = responseObject[@"url"] ;
                if (!url) {
                    [SVProgressHUD showErrorWithStatus:@"图片上传失败, 请检查网络"] ;
                }
                else { // success .
                    NSMutableString *tmpString = [self.text mutableCopy] ;
                    NSString *tickStr = @([[NSDate date] xt_getTick]).stringValue ;
                    NSString *imgStringWillInsert = XT_STR_FORMAT(@"![%@](%@)\n\n",tickStr,url) ;
                    [tmpString insertString:imgStringWillInsert atIndex:self.selectedRange.location] ;
                    [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
                    self.selectedRange = NSMakeRange(self.selectedRange.location + imgStringWillInsert.length + 3, 0) ;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
                }
            }) ;
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"图片上传失败, 请检查网络"] ;
            }) ;
        }] ;
        
    }) ;
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

- (void)toolbarDidSelectUndo {
    [[self undoManager] undo];
}
- (void)toolbarDidSelectRedo {
    [[self undoManager] redo];
}

@end
