//
//  OcContainerCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcContainerCell.h"
#import "OcNoteCell.h"

@implementation OcContainerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [OcNoteCell xt_registerNibFromCollection:self.contentCollection] ;
    self.contentCollection.dataSource = (id<UICollectionViewDataSource>)self ;
    self.contentCollection.delegate = (id<UICollectionViewDelegate>)self ;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    float wid = ( APP_WIDTH - 10. * 3 ) / 2. ;
    float height = wid  / 345. * 432. ;
    layout.itemSize = CGSizeMake(wid, height) ;
    layout.minimumLineSpacing = 10 ;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10) ;
    self.contentCollection.collectionViewLayout = layout ;
    
    @weakify(self)
    [[[[[RACObserve(self.contentCollection, contentOffset) map:^id _Nullable(NSValue *value) {
        CGPoint pt = value.CGPointValue ;
        return @(pt.y) ;
    }] filter:^BOOL(id  _Nullable value) {
        @strongify(self)
        return self.window != nil ;
    }]
       distinctUntilChanged]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self)
         NSLog(@"offset : %@",x) ;
         NSLog(@"self : %@",self) ;
         CGPoint point = [self.contentCollection.panGestureRecognizer translationInView:self] ;
         if (self.UIDelegate) [self.UIDelegate containerCellDraggingDirection:point.y < 0] ;
    }] ;
}


#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9 ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OcNoteCell *cell = [OcNoteCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    cell.backgroundColor = [UIColor blueColor] ;
    return cell ;
}



@end
