//
//  MDEKeyboardPhotoView.m
//  Notebook
//
//  Created by teason23 on 2019/3/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MDEKeyboardPhotoView.h"
#import <XTlib/XTlib.h>
#import <BlocksKit+UIKit.h>

@interface MDEKeyboardPhotoView ()

@end

@implementation MDEKeyboardPhotoView

+ (instancetype)showViewWhenUserPressedPhotoOnList:(void(^)(UIImage *image))blkPressedPhotoList
                                   cameraOnPressed:(void(^)(UIImage *image))blkPressCameraBt
                                    albumOnPressed:(void(^)(UIImage *image))blkPressAlbum
                                            cancel:(void(^)(void))blkCancel {
    
    MDEKeyboardPhotoView *photoView = [MDEKeyboardPhotoView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    [photoView.btViewCamera bk_whenTapped:^{
        
    }] ;
    [photoView.btViewAlbum bk_whenTapped:^{
        
    }] ;
    [photoView.btCancel bk_addEventHandler:^(id sender) {
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    
    
    return photoView ;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
