//
//  UnsplashVC.m
//  Notebook
//
//  Created by teason23 on 2019/9/24.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "UnsplashVC.h"
#import "UnsplashRequest.h"
#import "UnsplashPhoto.h"
#import "UnsplashCell.h"
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>

@interface UnsplashVC () <UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout>
@property (copy, nonatomic) NSArray *list ;
@end

@implementation UnsplashVC

+ (void)showMeFrom:(UIViewController *)fromCtrller {
    UnsplashVC *vc = [UnsplashVC getCtrllerFromStory:@"Home" controllerIdentifier:@"UnsplashVC"] ;
    
    [fromCtrller presentViewController:vc animated:YES completion:^{}] ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init] ;
    layout.columnCount = 2;
    layout.minimumInteritemSpacing = 10;
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10) ;
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight ;
    
    self.collectionView.collectionViewLayout = layout ;
    
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    [self.collectionView xt_setup] ;
    [UnsplashCell xt_registerNibFromCollection:self.collectionView] ;
    
    [UnsplashRequest photos:^(NSArray * _Nonnull list) {
        
        self.list = list ;
        [self.collectionView reloadData] ;
        
    }] ;
}

- (void)prepareUI {
    self.collectionView.xt_theme_backgroundColor =
    self.secBar.xt_theme_backgroundColor =
    self.topBar.xt_theme_backgroundColor = self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.bgSch.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, 0.03) ;
    self.bgSch.xt_cornerRadius = 4. ;
    self.bgSch.xt_borderWidth = .5 ;
    self.bgSch.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, 0.1) ;
    
    
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UnsplashCell *cell = [UnsplashCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    UnsplashPhoto *photo = self.list[indexPath.row] ;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:photo.url_small] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }] ;
    return cell ;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UnsplashPhoto *photo = self.list[indexPath.row] ;

    float scnWid = IS_IPAD ? 400 : APP_WIDTH ;
    float wid = (scnWid - 10. * 3.) / 2. ;
    return CGSizeMake(wid, wid / photo.width * photo.height) ;
}


@end
