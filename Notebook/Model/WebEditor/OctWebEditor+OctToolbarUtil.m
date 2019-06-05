//
//  OctWebEditor+OctToolbarUtil.m
//  Notebook
//
//  Created by teason23 on 2019/6/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OctWebEditor+OctToolbarUtil.h"
#import "MDEditUrlView.h"
#import "MDEKeyboardPhotoView.h"
#import "XTMarkdownParser+ImageUtil.h"

@implementation OctWebEditor (OctToolbarUtil)



- (CGFloat)keyboardHeight {
    return self->keyboardHeight ;
}

- (void)hideKeyboard {
    [self nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView  {
    @weakify(self)
    MDEKeyboardPhotoView *photoView =
    [MDEKeyboardPhotoView showViewFromCtrller:self.xt_viewController kbheight:keyboardHeight - 40 WhenUserPressedPhotoOnList:^(UIImage * _Nonnull image) {
        @strongify(self)
//        [self uploadImage:image] ;
    } cameraOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
//        [self uploadImage:image] ;
    } albumOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
//        [self uploadImage:image] ;
    } cancel:^{
        
    }] ;
    return photoView ;
}

//- (void)uploadImage:(UIImage *)image {
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        @weakify(self)
//        [self.parser.imgManager uploadImage:image progress:^(float pgs) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showProgress:pgs status:@"正在上传图片"]  ;
//            }) ;
//        } success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
//            @strongify(self)
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss] ;
//
//                NSString *url = responseObject[@"url"] ;
//                if (!url) {
//                    [SVProgressHUD showErrorWithStatus:@"图片上传失败, 请检查网络"] ;
//                }
//                else { // success .
//                    NSMutableString *tmpString = [self.text mutableCopy] ;
//                    NSString *tickStr = @([[NSDate date] xt_getTick]).stringValue ;
//                    NSString *imgStringWillInsert = XT_STR_FORMAT(@"![%@](%@)\n\n",tickStr,url) ;
//                    [tmpString insertString:imgStringWillInsert atIndex:self.selectedRange.location] ;
//                    [self.parser parseTextAndGetModelsInCurrentCursor:tmpString textView:self] ;
//                    self.selectedRange = NSMakeRange(self.selectedRange.location + imgStringWillInsert.length + 3, 0) ;
//
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_NAME_EDITOR_DID_CHANGE object:nil] ;
//                }
//            }) ;
//        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showErrorWithStatus:@"图片上传失败, 请检查网络"] ;
//            }) ;
//        }] ;
//
//    }) ;
//}

- (void)toolbarDidSelectUndo {
    [self nativeCallJSWithFunc:@"undo" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}
- (void)toolbarDidSelectRedo {
    [self getMarkdown:^(NSString *markdown) {
        
    }] ;
    
//    [self nativeCallJSWithFunc:@"redo" json:nil completion:^(BOOL isComplete) {
//
//    }] ;
}

- (UIView *)fromEditor {
    return self ;
}


@end
