//
//  SearchVC.h
//  Notebook
//
//  Created by teason23 on 2019/4/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"



NS_ASSUME_NONNULL_BEGIN

@interface SearchVC : BasicVC
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UIView *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topFlex;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;



+ (void)showSearchVCFrom:(UIViewController *)fromCtrller ;

#pragma mark - OcNoteCell call back  self.xt_viewcontroller
/**
 OcNoteCell call back
 */
- (void)noteCellDidSelectedBtMore:(Note *)aNote fromView:(UIView *)fromView ;

@end

NS_ASSUME_NONNULL_END
