//
//  MarkdownEditor+OctToolbarUtil.m
//  Notebook
//
//  Created by teason23 on 2019/5/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownEditor+OctToolbarUtil.h"
#import "MDEditUrlView.h"
#import "MDHeadModel.h"
#import "MdListModel.h"
#import "MdBlockModel.h"
#import "MdInlineModel.h"
#import "MDEKeyboardPhotoView.h"
#import "MDImageManager.h"
#import "XTMarkdownParser+Fetcher.h"
#import "MdInlineModel.h"



@implementation MarkdownEditor (OctToolbarUtil)

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
        blkModel.type = -1 ;
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










- (CGFloat)keyboardHeight {
    return self->keyboardHeight ;
}

- (void)hideKeyboard {
    [self resignFirstResponder] ;
}

- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView  {
    @weakify(self)
    MDEKeyboardPhotoView *photoView =
    [MDEKeyboardPhotoView showViewFromCtrller:self.xt_viewController kbheight:keyboardHeight - 40 WhenUserPressedPhotoOnList:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self uploadImage:image] ;
    } cameraOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self uploadImage:image] ;
    } albumOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self uploadImage:image] ;
    } cancel:^{

    }] ;
    return photoView ;
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

- (void)toolbarDidSelectUndo {
    [[self undoManager] undo] ;
}
- (void)toolbarDidSelectRedo {
    [[self undoManager] redo] ;
}

- (MarkdownEditor *)fromEditor {
    return self ;
}

@end
