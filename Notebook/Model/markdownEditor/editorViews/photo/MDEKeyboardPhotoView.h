//
//  MDEKeyboardPhotoView.h
//  Notebook
//
//  Created by teason23 on 2019/3/26.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XTlib/XTlib.h>

@class XTImageItem ;

NS_ASSUME_NONNULL_BEGIN

@interface MDEKeyboardPhotoView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *btViewCamera;
@property (weak, nonatomic) IBOutlet UIView *btViewAlbum;
@property (weak, nonatomic) IBOutlet UIView *btLink;
@property (weak, nonatomic) IBOutlet UIView *btUnsplash;
@property (weak, nonatomic) IBOutlet UIView *btOCR;


@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lightLabels;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *iconImgs;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *darkLabels;
@property (strong, nonatomic) UIScrollView *scrollView ;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *bts;


+ (instancetype)showViewFromCtrller:(UIViewController *)ctrller
                           kbheight:(CGFloat)height
         WhenUserPressedPhotoOnList:(void(^)(XTImageItem *image))blkPressedPhotoList
                    cameraOnPressed:(void(^)(XTImageItem *image))blkPressCameraBt
                     albumOnPressed:(void(^)(XTImageItem *image))blkPressAlbum
                        linkPressed:(void(^)(void))linkPressed
                    unsplashPressed:(void(^)(void))unsplashPressed
                         ocrPressed:(void(^)(void))ocrPressed ; 

@end

NS_ASSUME_NONNULL_END
