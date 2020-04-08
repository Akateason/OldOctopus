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
#import "WebPhotoHandler.h"
#import "OctRequestUtil.h"
#import "IAPSubscriptionVC.h"
#import "MarkdownVC.h"
#import "UnsplashVC.h"
#import "GuidingICloud.h"


#ifdef ISIOS
#import <AipOcrSdk/AipOcrSdk.h>
#endif


#import "OCRUtil.h"
#import <XTlib/XTImageItem.h>

@implementation OctWebEditor (OctToolbarUtil)

- (CGFloat)keyboardHeight {
    return self->keyboardHeight ;
}

- (void)hideKeyboard {
    [self nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(NSString *val, NSError *error) {

    }] ;
}

- (void)openKeyboard {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self nativeCallJSWithFunc:@"openKeyboard" json:nil completion:^(NSString *val, NSError *error) {}] ;
    }) ;
}


- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView  {
    @weakify(self)
    MDEKeyboardPhotoView *photoView =
    [MDEKeyboardPhotoView showViewFromCtrller:self.xt_viewController kbheight:keyboardHeight - OctToolbarHeight WhenUserPressedPhotoOnList:^(XTImageItem * _Nonnull image) {
        
        @strongify(self)
        if (![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist]) {
            [self subscription] ;
    
            return ;
        }
        
        [self sendImageLocalPathWithImageItem:image] ;
        
    } cameraOnPressed:^(XTImageItem * _Nonnull image) {
        // 照相生命周期问题, 交给VC处理
    } albumOnPressed:^(XTImageItem * _Nonnull image) {
        @strongify(self)
        if (![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist]) {
            [self subscription] ;
            
            return ;
        }
        self.toolBar.selectedPosition = 0 ;
        [self sendImageLocalPathWithImageItem:image] ;
    } linkPressed:^{
        @strongify(self)
        [self nativeCallJSWithFunc:@"addLink" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    } unsplashPressed:^{
        @strongify(self)
        [self.toolBar hideAllBoards] ;
        self.toolBar.selectedPosition = 0 ;

        [UnsplashVC showMeFrom:self.xt_viewController] ;
    } ocrPressed:^{
        @strongify(self)
        if (![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist]) {
            [self subscription] ;
            
            return ;
        }
        
        [self.toolBar hideAllBoards] ;
        self.toolBar.selectedPosition = 0 ;
        
#ifdef ISIOS
        
        __block UIViewController *vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {

            NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
            [[AipOcrService shardService] detectTextBasicFromImage:image
                                                       withOptions:options
                                                    successHandler:^(id result) {

                NSLog(@"ocr : %@", result);
                NSString *message = [OCRUtil parseResult:result] ;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [vc dismissViewControllerAnimated:YES completion:nil] ;

                    NSDictionary *dic = @{@"location":@"",
                                          @"text":message,
                                          @"outMost":@1
                    } ;
                    [self nativeCallJSWithFunc:@"insertParagraph" json:dic completion:^(NSString *val, NSError *error) {

                    }] ;

                }] ;


            } failHandler:^(NSError *err) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[err code], [err localizedDescription]];
                    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"识别失败" message:msg cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil fromWithView:self CallBackBlock:nil] ;

                    [vc dismissViewControllerAnimated:YES completion:nil] ;
                }];
            }];
        }];

        vc.modalPresentationStyle = UIModalPresentationFullScreen ;
        [self.xt_viewController presentViewController:vc animated:YES completion:nil] ;

#endif
        
    }] ;
    return photoView ;
}

- (void)sendImageLocalPathWithImageItem:(XTImageItem *)imageItem {
    WebPhoto *photo = [WebPhoto new] ;
    photo.fromNoteClientID = self.note_clientID ;
    photo.localPath = XT_STR_FORMAT(@"%d_%lld",self.note_clientID,[NSDate xt_getNowTick]) ;
    
//    float mb = [self mdFileSize:[imageItem.data length]] ;
//    if (mb > 5.) {
//        [SVProgressHUD showErrorWithStatus:@"超过限制\n请控制上传图片大小在5MB以内"] ;
//        return ;
//    }
    
    BOOL success = [imageItem.data writeToFile:photo.realPath atomically:YES] ;
    if (success) {
        [photo xt_insert] ;
        
        @weakify(self)
        [self nativeCallJSWithFunc:@"insertImage" json:@{@"src":photo.realPath} completion:^(NSString *val, NSError *error) { // 替换编辑器中
            @strongify(self)
            [self uploadWebPhoto:photo image:imageItem] ; // 上传
        }] ;
    }        
}

- (float)mdFileSize:(long long)size {
    long mb = 1024 * 1024;
    float f = (float) size / mb;
    return f ;
}


- (void)uploadWebPhoto:(WebPhoto *)photo image:(XTImageItem *)item {
    @weakify(self)
    [self uploadImage:item complete:^(NSString *url) {
        if (url.length) {
            NSLog(@"图片上传成功 : %@",url) ;
            photo.url = url ;
            photo.isUploaded = 1 ;
            [photo xt_update] ;
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self nativeCallJSWithFunc:@"replaceImage" json:@{@"oldSrc":photo.realPath,@"src":url} completion:^(NSString *val, NSError *error) {
                    NSLog(@"replaceImage : val %@ err%@",val, error) ;
                    if ([val boolValue]) {
                        [XTFileManager deleteFile:photo.realPath] ;
                        [photo xt_deleteModel] ; // 上传成功,删除photo
                    }
                    else {
                        NSLog(@"replaceImage FAIL err 图片替换失败") ;
                    }
                }] ;
            }) ;
        }
        else {
            NSLog(@"图片上传失败") ;
        }
    }] ;
}

- (void)uploadImage:(XTImageItem *)item
           complete:(void(^)(NSString *url))completion {
    
    [OctRequestUtil uploadImage:item progress:nil complete:completion] ;
}

- (void)toolbarDidSelectUndo {
    [self nativeCallJSWithFunc:@"undo" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (void)toolbarDidSelectRedo {
    [self nativeCallJSWithFunc:@"redo" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
}

- (UIView *)fromEditor {
    return self ;
}

- (void)subscription {
    MarkdownVC *vc = (MarkdownVC *)self.xt_viewController ;
    [IAPSubscriptionVC showMePresentedInFromCtrller:vc fromSourceView:self.toolBar.btPhoto isPresentState:YES] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.toolBar.selectedPosition = 0 ;
        [self.toolBar hideAllBoards] ;
        [self.webView resignFirstResponder] ;
    }) ;

}

@end
