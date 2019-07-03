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


@implementation OctWebEditor (OctToolbarUtil)

- (CGFloat)keyboardHeight {
    return self->keyboardHeight ;
}

- (void)hideKeyboard {
    [self nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(NSString *val, NSError *error) {
        
    }] ;
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
    photo.localPath = XT_DOCUMENTS_PATH_TRAIL_(XT_STR_FORMAT(@"%d_%lld.jpg",self.note_clientID,[NSDate xt_getNowTick])) ;
    NSData *data = UIImageJPEGRepresentation(image, 1) ;
    BOOL success = [data writeToFile:photo.localPath atomically:YES];
    if (success) {
        [photo xt_insert] ;
    
        @weakify(self)
        [self nativeCallJSWithFunc:@"insertImage" json:@{@"src":photo.localPath} completion:^(NSString *val, NSError *error) {
            @strongify(self)
            [self uploadWebPhoto:photo image:image] ;
        }] ;
    }        
}

- (void)uploadWebPhoto:(WebPhoto *)photo image:(UIImage *)image {
    @weakify(self)
    [self uploadImage:image complete:^(NSString *url) {
        NSLog(@"图片上传成功 : %@",url) ;
        if (url.length) {
            photo.url = url ;
            photo.isUploaded = 1 ;
            [photo xt_update] ;
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self nativeCallJSWithFunc:@"replaceImage" json:@{@"oldSrc":photo.localPath,@"src":url} completion:^(NSString *val, NSError *error) {
                    NSLog(@"replaceImage : val %@ err%@",val, error) ;
                    if ([val boolValue]) {
                        [XTFileManager deleteFile:photo.localPath] ;
                        [photo xt_deleteModel] ; // 上传成功,删除photo
                    }
                    else {
                        NSLog(@"replaceImage FAIL err") ;
                    }
                }] ;
            }) ;
            
        }
    }] ;
}

- (void)uploadImage:(UIImage *)image
           complete:(void(^)(NSString *url))completion {
    MDImageManager *imgManager = [MDImageManager new] ;

//    @weakify(self)
    [imgManager uploadImage:image progress:^(float pgs) {
        
    } success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
//        @strongify(self)

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *url = responseObject[@"url"] ;
            if (!url) {
                // upload failed
            }
            else { // success .
                completion(url) ;
            }
        }) ;
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
    }] ;
    
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
