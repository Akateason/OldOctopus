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

@interface UnsplashVC () <UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout,UICollectionViewXTReloader>
@property (copy, nonatomic) NSArray *list ;
@end

@implementation UnsplashVC

static int kPage_UnsplashVC = 1 ;

+ (void)showMeFrom:(UIViewController *)fromCtrller {
    UnsplashVC *vc = [UnsplashVC getCtrllerFromStory:@"Home" controllerIdentifier:@"UnsplashVC"] ;
    
    [fromCtrller presentViewController:vc animated:YES completion:^{}] ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init] ;
    layout.columnCount = 3;
    layout.minimumInteritemSpacing = 0;
    layout.minimumColumnSpacing = 10 ;
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20) ;
//    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight ;
    
    self.collectionView.collectionViewLayout = layout ;
    
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    [self.collectionView xt_setup] ;
    self.collectionView.xt_Delegate = self ;
    self.collectionView.xt_isAutomaticallyLoadMore = YES ;
    self.collectionView.mj_header = nil ;
    [UnsplashCell xt_registerNibFromCollection:self.collectionView] ;
    
    [UnsplashRequest photos:1 result:^(NSArray * _Nonnull list) {
        
        self.list = [NSArray arrayWithArray:list] ;
        [self.collectionView reloadData] ;
        
    }] ;
     
    
    @weakify(self)
    [[[[[[self.tfSearch.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 2 ;
    }] distinctUntilChanged]
        throttle:.8]
       deliverOnMainThread]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        
        @weakify(self)
        [UnsplashRequest search:x page:1 result:^(NSArray * _Nonnull list) {
            @strongify(self)
            self.list = [NSArray arrayWithArray:list] ;
            [self.collectionView reloadData] ;
        }] ;
        
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
    
    self.tfSearch.placeholder = @"搜索图片";
    
}

#pragma mark - collection

- (void)collectionView:(UICollectionView *)collection loadMore:(void (^)(void))endRefresh {
    kPage_UnsplashVC ++ ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.tfSearch.text.length > 0) {
            @weakify(self)
            [UnsplashRequest search:self.tfSearch.text page:kPage_UnsplashVC result:^(NSArray * _Nonnull list) {
                @strongify(self)
                NSMutableArray *tmplist = [self.list mutableCopy] ;
                [tmplist addObjectsFromArray:list] ;
                self.list = tmplist ;
                
                endRefresh() ;
            }] ;
        }
        else {
            [UnsplashRequest photos:kPage_UnsplashVC
                             result:^(NSArray * _Nonnull list) {
                                 
                                 NSMutableArray *tmplist = [self.list mutableCopy] ;
                                 [tmplist addObjectsFromArray:list] ;
                                 self.list = tmplist ;
                                 
                                 endRefresh() ;
                             }] ;
        }
        
    }) ;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UnsplashCell *cell = [UnsplashCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    UnsplashPhoto *photo = self.list[indexPath.row] ;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:photo.url_small] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        

    }] ;
    cell.lbName.text = photo.userName ;
    return cell ;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UnsplashPhoto *photo = self.list[indexPath.row] ;

    float scnWid = IS_IPAD ? 400 : APP_WIDTH ;
    float wid = (scnWid - 40. - 10. * 2.) / 3. ;
    return CGSizeMake(wid, wid / photo.width * photo.height + 25) ;
}

//- (void)collectionView:(UICollectionView *)collectionView
//       willDisplayCell:(UnsplashCell *)cell
//    forItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    [UIView animateWithDuration:.2 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
//        cell.imageView.transform = CGAffineTransformMakeScale(.8, .8) ;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.1 animations:^{
//            cell.imageView.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
//
//        }] ;
//    }] ;
//
//}

@end
