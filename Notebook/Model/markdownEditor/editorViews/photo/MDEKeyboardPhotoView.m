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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *h_collection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_collection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_collection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_list;

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
                        linkPressed:(void(^)(void))linkPressed
                    unsplashPressed:(void(^)(void))unsplashPressed {
    
    MDEKeyboardPhotoView *photoView = [MDEKeyboardPhotoView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    [photoView setupCollections:height] ;
    photoView.ctrller = ctrller ;
    photoView.blkFlowPressed = blkPressedPhotoList ;
    photoView.keyboardHeight = height ;
    [photoView setupUIs] ;
    
    @weakify(photoView)
    [photoView.btViewCamera bk_whenTapped:^{

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_User_Open_Camera object:nil] ;
        }) ;
    }] ;
    [photoView.btViewAlbum bk_whenTapped:^{
        @strongify(photoView)
        dispatch_async(dispatch_get_main_queue(), ^{
            [photoView albumAddCrop:blkPressAlbum] ;
        }) ;
    }] ;
    [photoView.btLink bk_whenTapped:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            linkPressed() ;
        }) ;
    }] ;
    
    [photoView.btUnsplash bk_whenTapped:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            unsplashPressed() ;
        }) ;
    }] ;
    
    [photoView addMeAboveKeyboardViewWithKeyboardHeight:height] ;
    
    return photoView ;
}

- (void)albumAddCrop:(void(^)(UIImage *image))blkGetImage {
    XTPAConfig *config = [[XTPAConfig alloc] init];
    config.albumSelectedMaxCount = 1;
    
    [XTPhotoAlbumVC openAlbumWithConfig:config fromCtrller:self.ctrller willDismiss:NO getResult:^(NSArray<UIImage *> *_Nonnull imageList, NSArray<PHAsset *> *_Nonnull assetList, XTPhotoAlbumVC *vc) {
        if (!imageList) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc dismissViewControllerAnimated:YES completion:nil];
            blkGetImage(imageList.firstObject) ;
        }) ;

    }];
}

- (void)addMeAboveKeyboardViewWithKeyboardHeight:(float)keyboardHeight {
    [self scrollView] ;
    UIView *backView = [UIView new] ;
    
    for (UIView *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
            
            [window addSubview:self.scrollView] ;
            [self.scrollView addSubview:backView] ;
            [backView addSubview:self] ;
            
            [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(window) ;
                make.height.equalTo(@(keyboardHeight)) ;
            }] ;
            
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.scrollView) ;
            }] ;
            
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(backView);
                make.width.equalTo(@(APP_WIDTH));
                make.height.equalTo(@379) ;
            }] ;
            
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.mas_bottom) ;
            }] ;
            
        }
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init] ;
        scrollView.backgroundColor = UIColorHex(@"f9f6f6") ;
        _scrollView = scrollView ;
    }
    return _scrollView ;
}





- (void)setupCollections:(CGFloat)keyboardHeight {
    [self setupAlbum] ;
    
    [MDEKPhotoViewCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    float cellHeight = keyboardHeight - 158. - 8. - 35. ;
    if (XT_LESS_THAN_IPHONE_6 || XT_IS_IPHONE_6) {
        self.top_collection.constant = 5 ;
        self.bottom_collection.constant = 5 ;
        cellHeight = keyboardHeight - 158. - 8. - 10. ;
    }
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
                [self.collectionView reloadData] ;
            });
        }
        else {
            // 用户拒绝授权
        }
    }];
}

- (void)setupUIs {
//    for (UIImage *img in self.iconImgs) {
//        img.xt_theme_imageColor = k_md_iconColor ;
//    }
    
    for (UILabel *lb in self.lightLabels) {
        lb.textColor = [UIColor colorWithWhite:0 alpha:.3] ;
    }
    
    for (UILabel *lb in self.darkLabels) {
        lb.textColor = [UIColor colorWithWhite:0 alpha:.8] ;
    }
    
    self.height_list.constant = k_open_Unspash ? 150. : 100. ;
    self.btUnsplash.hidden = !k_open_Unspash ;
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
    
    NSInteger row  = indexPath.row;
    PHAsset *photo = [self.allPhotos objectAtIndex:row];
    
    PHImageRequestOptions *option = [PHImageRequestOptions new] ;
    option.synchronous = YES ;
    
    [self.manager requestImageForAsset:photo
                            targetSize:CGSizeMake(self.keyboardHeight - 158., self.keyboardHeight - 158.)
                           contentMode:PHImageContentModeAspectFill
                               options:option
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                             if (result) cell.imgView.image = result;
                         }] ;
    
    return cell ;
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
                                         self.blkFlowPressed(result) ;
                                     }) ;
                                 }
                             }] ;
    }) ;
}

#pragma mark - props

- (PHImageManager *)manager {
    if (!_manager) {
        _manager = [PHImageManager defaultManager] ;
    }
    return _manager;
}

@end
