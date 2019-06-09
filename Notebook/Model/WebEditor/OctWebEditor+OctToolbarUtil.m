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
    [self nativeCallJSWithFunc:@"hideKeyboard" json:nil completion:^(BOOL isComplete) {
        
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
        [self nativeCallJSWithFunc:@"addLink" json:nil completion:^(BOOL isComplete) {
            
        }] ;
    }] ;
    return photoView ;
}

- (void)sendImageLocalPathWithImage:(UIImage *)image {
    WebPhoto *photo = [WebPhoto new] ;
    photo.fromNoteClientID = self.note_clientID ;
    photo.localPath = XT_DOCUMENTS_PATH_TRAIL_(XT_STR_FORMAT(@"%d_%lld.jpg",self.note_clientID,[NSDate xt_getNowTick])) ;
    NSData *data = UIImageJPEGRepresentation(image, 1) ;
    [data writeToFile:photo.localPath atomically:YES] ;
    
    [photo xt_insert] ;
    
    [self uploadWebPhoto:photo image:image] ;
    
    [self nativeCallJSWithFunc:@"insertImage" json:[@{@"src":photo.localPath} yy_modelToJSONString] completion:^(BOOL isComplete) {
    }] ;
}

- (void)uploadWebPhoto:(WebPhoto *)photo image:(UIImage *)image {
    @weakify(self)
    [self uploadImage:image complete:^(NSString *url) {
        if (url.length) {
            photo.url = url ;
            photo.isUploaded = 1 ;
            [photo xt_update] ;
            @strongify(self)
            [self nativeCallJSWithFunc:@"replaceImage" json:[@{@"oldSrc":photo.localPath,@"src":url} yy_modelToJSONString] completion:^(BOOL isComplete) {
                
            }] ;
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
    [self nativeCallJSWithFunc:@"undo" json:nil completion:^(BOOL isComplete) {
        
    }] ;
}

- (void)toolbarDidSelectRedo {
    [self nativeCallJSWithFunc:@"redo" json:nil completion:^(BOOL isComplete) {

    }] ;
}

- (UIView *)fromEditor {
    return self ;
}


@end
