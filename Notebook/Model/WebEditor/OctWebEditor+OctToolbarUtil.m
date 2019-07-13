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

@implementation OctWebEditor (OctToolbarUtil)

- (CGFloat)keyboardHeight {
    return self->keyboardHeight ;
}

- (void)hideKeyboard {
    [self nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(NSString *val, NSError *error) {
//        complete() ;
    }] ;
}

- (void)openKeyboard {
    [self nativeCallJSWithFunc:@"openKeyboard" json:nil completion:^(NSString *val, NSError *error) {}] ;
}


- (MDEKeyboardPhotoView *)toolbarDidSelectPhotoView  {
    @weakify(self)
    MDEKeyboardPhotoView *photoView =
    [MDEKeyboardPhotoView showViewFromCtrller:self.xt_viewController kbheight:keyboardHeight - 40 WhenUserPressedPhotoOnList:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self sendImageLocalPathWithImage:image] ;
    } cameraOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self sendImageLocalPathWithImage:image] ;
    } albumOnPressed:^(UIImage * _Nonnull image) {
        @strongify(self)
        [self sendImageLocalPathWithImage:image] ;
    } linkPressed:^{
        @strongify(self)
        [self nativeCallJSWithFunc:@"addLink" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }] ;
    return photoView ;
}

- (void)sendImageLocalPathWithImage:(UIImage *)image {
    WebPhoto *photo = [WebPhoto new] ;
    photo.fromNoteClientID = self.note_clientID ;
    // todo 图片类型
    photo.localPath = XT_STR_FORMAT(@"%d_%lld.jpg",self.note_clientID,[NSDate xt_getNowTick]) ;
    NSData *data = UIImageJPEGRepresentation(image, 1) ;
    BOOL success = [data writeToFile:photo.realPath atomically:YES];
    if (success) {
        [photo xt_insert] ;
    
        @weakify(self)
        [self nativeCallJSWithFunc:@"insertImage" json:@{@"src":photo.realPath} completion:^(NSString *val, NSError *error) {
            @strongify(self)
            [self uploadWebPhoto:photo image:image] ;
        }] ;
    }        
}

- (void)uploadWebPhoto:(WebPhoto *)photo image:(UIImage *)image {
    @weakify(self)
    [self uploadImage:image complete:^(NSString *url) {
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
                        NSLog(@"replaceImage FAIL err") ;
                    }
                }] ;
            }) ;
        }
        else {
            NSLog(@"图片上传失败") ;
        }
    }] ;
}

- (void)uploadImage:(UIImage *)image
           complete:(void(^)(NSString *url))completion {
    
    [OctRequestUtil uploadImage:image progress:nil complete:completion] ;
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

@end
