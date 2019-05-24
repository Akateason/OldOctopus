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
#import <XTlib/XTPhotoAlbum.h>
#import <Photos/Photos.h>
#import "MDEKPhotoViewCell.h"

typedef void(^BlkCollectionFlowPressed)(UIImage *image);

@interface MDEKeyboardPhotoView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UIViewController *ctrller ;
@property (strong, nonatomic) XTCameraHandler *handler;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h_collection;

@property (copy, nonatomic) BlkCollectionFlowPressed blkFlowPressed ;
@property (strong, nonatomic) PHImageManager *manager;
@property (strong, nonatomic) PHFetchResult *allPhotos;
@property (nonatomic) float keyboardHeight ;
@end

@implementation MDEKeyboardPhotoView

+ (instancetype)showViewFromCtrller:(UIViewController *)ctrller
                           kbheight:(CGFloat)height
         WhenUserPressedPhotoOnList:(void(^)(UIImage *image))blkPressedPhotoList
                    cameraOnPressed:(void(^)(UIImage *image))blkPressCameraBt
                     albumOnPressed:(void(^)(UIImage *image))blkPressAlbum
                             cancel:(void(^)(void))blkCancel {
    
    MDEKeyboardPhotoView *photoView = [MDEKeyboardPhotoView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    [photoView setupCollections:height] ;
    photoView.ctrller = ctrller ;
    photoView.blkFlowPressed = blkPressedPhotoList ;
    photoView.keyboardHeight = height ;
    
    @weakify(photoView)
    [photoView.btViewCamera bk_whenTapped:^{
        @strongify(photoView)
        dispatch_async(dispatch_get_main_queue(), ^{
            [photoView cameraAddCrop:blkPressCameraBt] ;
//            [photoView removeFromSuperview] ;
        }) ;
    }] ;
    [photoView.btViewAlbum bk_whenTapped:^{
        @strongify(photoView)
        dispatch_async(dispatch_get_main_queue(), ^{
            [photoView albumAddCrop:blkPressAlbum] ;
//            [photoView removeFromSuperview] ;
        }) ;
    }] ;
    [photoView.btCancel bk_addEventHandler:^(id sender) {
        @strongify(photoView)
        dispatch_async(dispatch_get_main_queue(), ^{
            blkCancel() ;
//            [photoView removeFromSuperview] ;
        }) ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [photoView addMeAboveKeyboardViewWithKeyboardHeight:height] ;
    
    return photoView ;
}

- (void)albumAddCrop:(void(^)(UIImage *image))blkGetImage {
    XTPAConfig *config = [[XTPAConfig alloc] init];
    config.albumSelectedMaxCount = 1;
    
    [XTPhotoAlbumVC openAlbumWithConfig:config fromCtrller:self.ctrller willDismiss:NO getResult:^(NSArray<UIImage *> *_Nonnull imageList, NSArray<PHAsset *> *_Nonnull assetList, XTPhotoAlbumVC *vc) {
        if (!imageList) return;
        
//        @weakify(vc)
//        [XTPACropImageVC showFromCtrller:vc imageOrigin:imageList.firstObject croppedImageCallback:^(UIImage *_Nonnull image) {
//            @strongify(vc)
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc dismissViewControllerAnimated:YES completion:nil];
                blkGetImage(imageList.firstObject) ;
            }) ;
//        }];
    }];
}

- (void)cameraAddCrop:(void(^)(UIImage *image))blkGetImage {
    @weakify(self)
    XTCameraHandler *handler = [[XTCameraHandler alloc] init];
    [handler openCameraFromController:self.ctrller takePhoto:^(UIImage *imageResult) {
        if (!imageResult) return;
        
        @strongify(self)
//        [XTPACropImageVC showFromCtrller:self.ctrller imageOrigin:imageResult croppedImageCallback:^(UIImage *_Nonnull image){
            blkGetImage(imageResult) ;
//        }];
    }];
    self.handler = handler;
}

- (void)addMeAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight {
    for (UIView *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            [window addSubview:self] ;
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(window) ;
                make.height.equalTo(@(keyboardHeight)) ;
            }] ;
        }
    }
}

- (void)setupCollections:(CGFloat)keyboardHeight {
    [self setupAlbum] ;
    
    [MDEKPhotoViewCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    float cellHeight = keyboardHeight - 158. ;
    layout.itemSize = CGSizeMake(cellHeight, cellHeight) ;
    layout.minimumInteritemSpacing = 6.0f ;
    self.h_collection.constant = cellHeight - APP_SAFEAREA_TABBAR_FLEX ;
    self.collectionView.collectionViewLayout = layout ;
}

- (void)setupAlbum {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // 用户同意授权
            [self firstLoadAllPhotos];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        else {
            // 用户拒绝授权
        }
    }];
}

- (void)firstLoadAllPhotos {
    if (self.allPhotos.count) return;
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init] ;
    allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage] ;
    allPhotosOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
    allPhotosOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary ;
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions] ;
    self.allPhotos           = allPhotos ;
}

#pragma mark - collection dataSourse

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1 ;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDEKPhotoViewCell *cell = [MDEKPhotoViewCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    return cell ;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MDEKPhotoViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row  = indexPath.row;
    PHAsset *photo = [self.allPhotos objectAtIndex:row];
    [self.manager requestImageForAsset:photo
                            targetSize:CGSizeMake(self.keyboardHeight - 158., self.keyboardHeight - 158.)
                           contentMode:PHImageContentModeAspectFill
                               options:nil
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                             if (result) cell.imgView.image = result;
                         }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row  = indexPath.row;
    PHAsset *photo = [self.allPhotos objectAtIndex:row];

    dispatch_async(dispatch_get_main_queue(), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode             = PHImageRequestOptionsResizeModeFast;
        options.synchronous            = YES;
        @weakify(self)
        [self.manager requestImageForAsset:photo
                                targetSize:PHImageManagerMaximumSize
                               contentMode:PHImageContentModeDefault
                                   options:options
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 @strongify(self)
                                 if (result) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                         @weakify(self)
//                                         [XTPACropImageVC showFromCtrller:self.ctrller imageOrigin:result croppedImageCallback:^(UIImage *_Nonnull image){
//                                             @strongify(self)
//                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 self.blkFlowPressed(result) ;
//                                                 [self removeFromSuperview] ;
//                                             }) ;
//                                         }];
                                     }) ;
                                 }
                             }] ;
    }) ;
}

#pragma mark - props

- (PHImageManager *)manager {
    if (!_manager) {
        _manager = [PHImageManager defaultManager];
    }
    return _manager;
}

@end
