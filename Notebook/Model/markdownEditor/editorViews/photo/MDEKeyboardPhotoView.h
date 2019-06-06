//
//  MDEKeyboardPhotoView.h
//  Notebook
//
//  Created by teason23 on 2019/3/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDEKeyboardPhotoView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *btViewCamera;
@property (weak, nonatomic) IBOutlet UIView *btViewAlbum;
@property (weak, nonatomic) IBOutlet UIView *btLink;

+ (instancetype)showViewFromCtrller:(UIViewController *)ctrller
                           kbheight:(CGFloat)height
         WhenUserPressedPhotoOnList:(void(^)(UIImage *image))blkPressedPhotoList
                    cameraOnPressed:(void(^)(UIImage *image))blkPressCameraBt
                     albumOnPressed:(void(^)(UIImage *image))blkPressAlbum
                             cancel:(void(^)(void))blkCancel ;

@end

NS_ASSUME_NONNULL_END
