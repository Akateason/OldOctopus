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
    
    //
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
    
    //
    [self btAdd] ;
    self.btAdd.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    //[UIColor blackColor].CGColor ;
    //[UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor ;
    self.btAdd.layer.shadowOffset = CGSizeMake(0, 7.5) ;
    self.btAdd.layer.shadowOpacity = 15 ;
    self.btAdd.layer.shadowRadius = 5 ;
}


@end
