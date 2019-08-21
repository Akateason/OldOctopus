//
//  OcHomeVC+UIPart.m
//  Notebook
//
//  Created by teason23 on 2019/8/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC+UIPart.h"

@implementation OcHomeVC (UIPart)

- (void)xt_prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    [OcBookCell      xt_registerNibFromCollection:self.bookCollectionView] ;
    [OcContainerCell xt_registerNibFromCollection:self.mainCollectionView] ;
    
    self.bookCollectionView.delegate    = (id<UICollectionViewDelegate>)self ;
    self.bookCollectionView.dataSource  = (id<UICollectionViewDataSource>)self ;
    self.mainCollectionView.delegate    = (id<UICollectionViewDelegate>)self ;
    self.mainCollectionView.dataSource  = (id<UICollectionViewDataSource>)self ;
    self.mainCollectionView.pagingEnabled = YES ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - 134.) ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    layout.minimumLineSpacing = 0 ;
    self.mainCollectionView.collectionViewLayout = layout ;
    
}


@end
